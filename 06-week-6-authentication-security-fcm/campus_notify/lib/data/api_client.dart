import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(TokenStore store, AuthRepository auth) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example-campus-api.test',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        final is401 = e.response?.statusCode == 401;
        final alreadyRetried = e.requestOptions.extra['retried'] == true;
        // Refresh hanya SATU kali per request.
        if (!is401 || alreadyRetried) return handler.next(e);

        final refresh = await store.readRefresh();
        if (refresh == null) return handler.next(e);

        final String renewed;
        try {
          renewed = await auth.refresh(refresh);
          await store.save(access: renewed, refresh: refresh);
        } catch (_) {
          await store.clear(); // refresh ikut mati -> paksa login ulang
          return handler.next(e);
        }

        try {
          final options = e.requestOptions
            ..headers['Authorization'] = 'Bearer $renewed'
            ..extra['retried'] = true;
          final retry = await dio.fetch<dynamic>(options);
          return handler.resolve(retry);
        } on DioException catch (retryError) {
          // Gagal bukan karena sesi: teruskan, jangan logout.
          return handler.next(retryError);
        }
      },
    ),
  );
  return dio;
}