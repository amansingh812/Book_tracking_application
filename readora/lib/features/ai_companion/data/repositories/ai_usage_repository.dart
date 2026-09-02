import 'package:supabase_flutter/supabase_flutter.dart';

class AiUsageInfo {
  const AiUsageInfo({required this.used, required this.limit, required this.isPlus});
  final int used;
  final int limit;
  final bool isPlus;
}

/// Read-only view of `public.ai_usage` for the current calendar month.
///
/// The row is written exclusively by `consume_ai_credit()` (service role,
/// called from the Edge Functions) and only created on first use — an absent
/// row just means zero interactions so far this month, not an error.
class AiUsageRepository {
  AiUsageRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<AiUsageInfo> fetchCurrent({required bool isPlus, required int freeLimit}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return AiUsageInfo(used: 0, limit: freeLimit, isPlus: isPlus);

    final now = DateTime.now();
    final periodMonth = DateTime.utc(now.year, now.month, 1).toIso8601String().split('T').first;

    try {
      final row = await _supabase
          .from('ai_usage')
          .select('interactions')
          .eq('user_id', userId)
          .eq('period_month', periodMonth)
          .maybeSingle();

      final used = (row?['interactions'] as int?) ?? 0;
      return AiUsageInfo(used: used, limit: freeLimit, isPlus: isPlus);
    } catch (_) {
      return AiUsageInfo(used: 0, limit: freeLimit, isPlus: isPlus);
    }
  }
}
