import 'package:dio/dio.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
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
        if (!is401 || alreadyRetried) return handler.next(e);

        final refresh = await store.readRefresh();
        if (refresh == null) return handler.next(e);

        final String renewed;
        try {
          renewed = await auth.refresh(refresh);
          await store.save(access: renewed, refresh: refresh);
        } catch (_) {
          await store.clear();
          return handler.next(e);
        }

        try {
          final options = e.requestOptions
            ..headers['Authorization'] = 'Bearer $renewed'
            ..extra['retried'] = true;
          return handler.resolve(await dio.fetch<dynamic>(options));
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      },
    ),
  );

  return dio;
}