import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:readora/features/ai_companion/domain/repositories/ai_chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/env.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  final SupabaseClient supabaseClient;

  AiChatRepositoryImpl(this.supabaseClient);

  /// Calls the `ai-chat` Supabase Edge Function and streams the SSE response.
  ///
  /// The edge function returns an OpenAI-compatible SSE stream:
  ///   data: {"choices":[{"delta":{"content":"Hello"}}]}
  ///   data: [DONE]
  ///
  /// We parse each `data:` line, extract `content`, and yield it.
  @override
  Stream<String> sendMessage({
    required String message,
    required String? bookId,
    required List<Map<String, String>> previousMessages,
  }) async* {
    // Build the edge function URL from the Supabase project URL.
    // e.g. https://xyz.supabase.co/functions/v1/ai-chat
    final restUrl = supabaseClient.rest.url; // https://xyz.supabase.co/rest/v1
    final projectUrl = restUrl.replaceFirst('/rest/v1', '');
    final functionUrl = Uri.parse('$projectUrl/functions/v1/ai-chat');

    // Use the current user's JWT if authenticated, fallback to anon key.
    final session = supabaseClient.auth.currentSession;
    final token = session?.accessToken ?? Env.supabaseAnonKey;

    // Stream SSE directly — functions.invoke() doesn't support streaming.
    yield* _fetchStream(
      url: functionUrl,
      token: token,
      body: {
        'message': message,
        if (bookId != null) 'bookId': bookId,
        'previousMessages': previousMessages,
      },
    );
  }

  Stream<String> _fetchStream({
    required Uri url,
    required String token,
    required Map<String, dynamic> body,
  }) async* {
    final client = HttpClient();

    try {
      developer.log('Sending AI request to: $url', name: 'AiChatRepository');
      final request = await client.postUrl(url);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'text/event-stream');
      request.write(jsonEncode(body));

      final response = await request.close();

      if (response.statusCode != 200) {
        final errorBody = await response.transform(utf8.decoder).join();
        developer.log(
            'AI Request failed with status ${response.statusCode}: $errorBody',
            name: 'AiChatRepository',
            error: errorBody);

        if (response.statusCode == 404) {
          throw Exception(
              'Edge function not found (404). Check that "supabase start" or "supabase functions serve" is running, and the function name is correct: $url');
        }

        throw Exception('ai-chat error ${response.statusCode}: $errorBody');
      }

      final buffer = StringBuffer();

      await for (final data in response.transform(utf8.decoder)) {
        buffer.write(data);
        final raw = buffer.toString();
        buffer.clear();

        // SSE lines are separated by '\n'. Process complete lines only.
        final lines = raw.split('\n');

        // The last segment may be incomplete — keep it in the buffer.
        for (var i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (!line.startsWith('data:')) continue;

          final payload = line.substring(5).trim();
          if (payload == '[DONE]') return;

          try {
            final json = jsonDecode(payload) as Map<String, dynamic>;
            final choices = json['choices'] as List<dynamic>?;
            final delta = choices?.first['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              yield content;
            }
          } catch (_) {
            // Skip malformed SSE lines (e.g. comment lines, keep-alives)
          }
        }

        // Keep the incomplete last line in the buffer for the next chunk.
        if (lines.last.isNotEmpty) {
          buffer.write(lines.last);
        }
      }
    } finally {
      client.close();
    }
  }
}
