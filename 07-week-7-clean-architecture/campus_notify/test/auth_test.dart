import 'dart:typed_data';

import 'package:campus_notify/data/api_client.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_secure_storage.dart';

/// Server palsu: menentukan status code dari setiap request.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._respond);

  final int Function(RequestOptions options) _respond;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(
      '{}',
      _respond(options),
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

({Dio dio, TokenStore store, _FakeAdapter adapter}) _setup(
  int Function(RequestOptions) respond,
) {
  final store = TokenStore(storage: FakeSecureStorage());
  final dio = buildApiClient(store, AuthRepository());
  final adapter = _FakeAdapter(respond);
  dio.httpClientAdapter = adapter;
  return (dio: dio, store: store, adapter: adapter);
}

void main() {
  group('TokenStore', () {
    test('menyimpan, membaca, dan menghapus token', () async {
      final store = TokenStore(storage: FakeSecureStorage());

      await store.save(access: 'a1', refresh: 'r1');
      expect(await store.readAccess(), 'a1');
      expect(await store.readRefresh(), 'r1');

      await store.clear();
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
    });
  });

  group('Refresh token otomatis (Dio)', () {
    test('401 -> refresh -> request diulang dan berhasil', () async {
      final t = _setup((o) {
        final auth = o.headers['Authorization'] as String?;
        return (auth?.contains('renewed') ?? false) ? 200 : 401;
      });
      await t.store
          .save(access: 'kedaluwarsa', refresh: 'mock-refresh-for-a@b.c');

      final response = await t.dio.get<dynamic>('/ping');

      expect(response.statusCode, 200);
      expect(t.adapter.calls, 2); // request awal + satu pengulangan
      expect(await t.store.readAccess(), startsWith('mock-access-renewed-'));
      expect(await t.store.readRefresh(), 'mock-refresh-for-a@b.c');
    });

    test('refresh gagal -> token dihapus (paksa login ulang)', () async {
      final t = _setup((_) => 401);
      await t.store.save(access: 'kedaluwarsa', refresh: ''); // refresh kosong

      await expectLater(
        t.dio.get<dynamic>('/ping'),
        throwsA(isA<DioException>()),
      );
      expect(await t.store.readAccess(), isNull);
      expect(await t.store.readRefresh(), isNull);
    });

    test('tetap 401 setelah refresh -> berhenti, tidak berulang terus',
        () async {
      final t = _setup((_) => 401);
      await t.store
          .save(access: 'kedaluwarsa', refresh: 'mock-refresh-for-a@b.c');

      await expectLater(
        t.dio.get<dynamic>('/ping'),
        throwsA(isA<DioException>()),
      );
      expect(t.adapter.calls, 2); // hanya SATU kali percobaan ulang
    });

    test('tanpa refresh token -> error diteruskan', () async {
      final t = _setup((_) => 401);

      await expectLater(
        t.dio.get<dynamic>('/ping'),
        throwsA(isA<DioException>()),
      );
      expect(t.adapter.calls, 1);
    });
  });

  group('AuthNotifier', () {
    late FakeSecureStorage storage;
    late ProviderContainer container;

    setUp(() {
      storage = FakeSecureStorage();
      container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(TokenStore(storage: storage)),
        ],
      );
      addTearDown(container.dispose);
    });

    test('awalnya belum login', () async {
      expect(await container.read(authStateProvider.future), false);
    });

    test('login berhasil menyimpan token dan status menjadi true', () async {
      await container.read(authStateProvider.future);

      await container
          .read(authStateProvider.notifier)
          .login('a@kampus.ac.id', 'rahasia1');

      expect(container.read(authStateProvider).value, true);
      expect(storage.data['access_token'], 'mock-access-for-a@kampus.ac.id');
      expect(storage.data['refresh_token'], 'mock-refresh-for-a@kampus.ac.id');
    });

        test('login gagal -> error dan tidak ada token tersimpan', () async {
      await container.read(authStateProvider.future);

      await container
          .read(authStateProvider.notifier)
          .login('tanpa-at', '123');

      expect(container.read(authStateProvider).hasError, true);
      expect(storage.data, isEmpty);
    });

    test('logout menghapus token', () async {
      await container.read(authStateProvider.future);
      await container
          .read(authStateProvider.notifier)
          .login('a@kampus.ac.id', 'rahasia1');

      await container.read(authStateProvider.notifier).logout();

      expect(storage.data, isEmpty);
      expect(await container.read(authStateProvider.future), false);
    });
  });
}