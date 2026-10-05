import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart'; // untuk dioProvider
import 'repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// AsyncNotifier dengan parameter postId (family).
/// Exception dari build() otomatis menjadi AsyncError,
/// tidak perlu try/catch manual.
class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  CommentsNotifier(this.postId);
  final int postId;

  @override
  Future<List<Comment>> build() {
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(postId);
  }
}

final commentsProvider =
    AsyncNotifierProvider.family<CommentsNotifier, List<Comment>, int>(
  CommentsNotifier.new,
  // Matikan retry otomatis Riverpod 3 supaya error langsung final.
  retry: (retryCount, error) => null,
);

/// Mengubah exception teknis menjadi pesan ramah pengguna.
String friendlyCommentError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Komentar tidak ditemukan (404).';
        if (code != null && code >= 500) {
          return 'Server sedang bermasalah ($code). Coba lagi nanti.';
        }
        return 'Permintaan gagal ($code). Coba lagi.';
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  return 'Terjadi kesalahan tak terduga.';
}