import 'package:dio/dio.dart';

String friendlyApiError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout. Periksa internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) return 'Sesi berakhir. Silakan login ulang.';
        if (code == 403) return 'Akses ditolak.';
        if (code == 404) return 'Data tidak ditemukan.';
        if (code != null && code >= 500) {
          return 'Server bermasalah ($code). Coba lagi nanti.';
        }
        return 'Permintaan gagal ($code).';
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  return 'Terjadi kesalahan tak terduga.';
}