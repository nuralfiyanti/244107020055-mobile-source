import 'package:dio/dio.dart';

import '../features/auth/domain/repositories/auth_repository.dart';
import 'token_store.dart';

class _CacheEntry {
  final Response<dynamic> response;
  final DateTime cachedAt;

  const _CacheEntry({required this.response, required this.cachedAt});
}

/// Interceptor cache in-memory ringan untuk request GET yang sukses (TTL 30 detik).
class _GetResponseCacheInterceptor extends Interceptor {
  static const Duration _ttl = Duration(seconds: 30);
  static const int _maxEntries = 50;
  final Map<String, _CacheEntry> _cache = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'GET' &&
        options.extra['skipCache'] != true) {
      final key = options.uri.toString();
      final entry = _cache[key];
      if (entry != null) {
        if (DateTime.now().difference(entry.cachedAt) < _ttl) {
          return handler.resolve(entry.response);
        }
        _cache.remove(key);
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      if (_cache.length >= _maxEntries) {
        _cache.remove(_cache.keys.first);
      }
      _cache[response.requestOptions.uri.toString()] = _CacheEntry(
        response: response,
        cachedAt: DateTime.now(),
      );
    }
    handler.next(response);
  }
}

Dio buildApiClient(TokenStore store, AuthRepository auth) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example-campus-api.test',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.addAll([
    _GetResponseCacheInterceptor(),
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
  ]);

  return dio;
}
