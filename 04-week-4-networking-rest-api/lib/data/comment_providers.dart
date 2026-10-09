import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart'; // dioProvider
import 'repositories/comment_repository.dart';

/// Repository komentar, memakai Dio terpusat dari dioProvider.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// Notifier komentar per post. `postId` diterima lewat constructor
/// (pola family di Riverpod 3).
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  CommentListNotifier(this.postId);

  final int postId;

  @override
  Future<List<Comment>> build() async {
    // Exception dari repository otomatis menjadi AsyncError,
    // tidak perlu try/catch manual.
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(postId);
  }
}

/// Provider family: satu state per postId.
final commentListProvider = AsyncNotifierProvider.family<
    CommentListNotifier, List<Comment>, int>(
  CommentListNotifier.new,
  // Matikan retry otomatis Riverpod 3 agar error langsung final.
  retry: (retryCount, error) => null,
);
