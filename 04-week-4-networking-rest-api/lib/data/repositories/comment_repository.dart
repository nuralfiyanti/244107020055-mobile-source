import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Satu-satunya pintu ke API untuk data komentar.
/// Dio di-inject lewat constructor, sehingga baseUrl dan timeout
/// tetap terpusat di createDio() (api_client.dart).
class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      // Query parameter menghasilkan: /comments?postId=1
      queryParameters: {'postId': postId},
      // Timeout 10 detik khusus request ini, sesuai requirement.
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    // `?? []` melindungi kalau body null.
    final data = response.data ?? [];
    // whereType membuang elemen yang bukan Map, jadi tidak crash.
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
    // Exception sengaja TIDAK ditangkap di sini. Dibiarkan naik
    // supaya provider mengubahnya menjadi AsyncError.
  }
}