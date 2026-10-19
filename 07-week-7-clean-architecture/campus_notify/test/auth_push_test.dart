import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/features/auth/presentation/providers/auth_providers.dart';
import 'package:campus_notify/routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTokenStore implements TokenStore {
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> save({required String access, required String refresh}) async {
    accessToken = access;
    refreshToken = refresh;
  }

  @override
  Future<String?> readAccess() async => accessToken;

  @override
  Future<String?> readRefresh() async => refreshToken;

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }
}

void main() {
  group('AppRoutes.fromFcmData', () {
    test('mengembalikan null untuk route kosong', () {
      expect(AppRoutes.fromFcmData({}), isNull);
    });

    test('menambahkan slash untuk route tanpa slash', () {
      expect(
        AppRoutes.fromFcmData({'route': 'pengumuman/3'}),
        '/pengumuman/3',
      );
    });

    test('mempertahankan slash untuk route dengan slash', () {
      expect(
        AppRoutes.fromFcmData({'route': '/pengumuman/3'}),
        '/pengumuman/3',
      );
    });

    test('memproses payload route dengan id', () {
      expect(
        AppRoutes.fromFcmData({'route': '/pengumuman/3', 'id': '3'}),
        '/pengumuman/3',
      );
    });
  });

  group('AuthNotifier', () {
    test('status login true saat token ada dan false setelah logout', () async {
      final fake = FakeTokenStore()..accessToken = 'access-token';
      final container = ProviderContainer(
        overrides: [tokenStoreProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      expect(await container.read(authStateProvider.future), true);

      await container.read(authStateProvider.notifier).logout();

      expect(await container.read(authStateProvider.future), false);
      expect(fake.accessToken, isNull);
    });
  });

  group('friendlyApiError', () {
    test('connection error berisi pesan terhubung', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      );

      expect(friendlyApiError(error), contains('terhubung'));
    });

    test('receive timeout berisi pesan timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.receiveTimeout,
      );

      expect(friendlyApiError(error), contains('timeout'));
    });
  });
}
