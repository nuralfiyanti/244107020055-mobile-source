import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Satu-satunya pintu data untuk komentar. UI tidak boleh memanggil Dio
/// langsung; UI cukup membaca provider yang memakai repository ini.
class CommentRepository {
  CommentRepository(this._dio);

  final Dio _dio;

  /// Mengambil komentar milik satu post.
  /// Endpoint: GET /comments?postId={postId}
  ///
  /// Timeout 10 detik tidak ditulis di sini: sudah diatur terpusat
  /// di createDio() (api_client.dart), jadi berlaku untuk semua request.
  ///
  /// Exception (DioException) sengaja tidak ditangkap di sini supaya
  /// naik ke provider dan otomatis menjadi AsyncError.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );

    // Data bisa null, dan elemen list bisa bukan Map: disaring dulu
    // sebelum diubah menjadi model.
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}