import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AiChatRepository {
  /// Sends a message to the AI and yields a stream of response chunks.
  Stream<String> sendMessage({
    required String message,
    required String? bookId,
    required List<Map<String, String>> previousMessages,
  });
}
