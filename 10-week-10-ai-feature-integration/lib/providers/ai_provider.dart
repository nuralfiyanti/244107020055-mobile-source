import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/ai_service.dart';

/// Provider global untuk [AiService].
/// Dibuat sebagai singleton per scope Riverpod agar cache & rate-limiter
/// dibagikan ke seluruh widget tree.
final aiServiceProvider = Provider<AiService>((ref) => AiService());

/// FutureProvider.family untuk memanggil [AiService.ask] dengan [question].
///
/// Contoh penggunaan di widget:
/// ```dart
/// ref.watch(aiResponseProvider('Jadwal kuliah hari ini?'))
/// ```
final aiResponseProvider =
    FutureProvider.family<String, String>((ref, question) async {
  final service = ref.read(aiServiceProvider);
  return service.ask(question);
});

