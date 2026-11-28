import 'dart:convert';
import 'dart:typed_data';

import 'package:campus_notify/ai/ai_service.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/data/api_client.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/features/auth/domain/entities/user.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/chat_screen.dart';
import 'package:campus_notify/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:campus_notify/features/notes/presentation/pages/notes_page.dart';
import 'package:campus_notify/providers/ai_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _MemoryTokenStore extends TokenStore {
  String? _access = 'token-1';
  String? _refresh = 'refresh-1';

  _MemoryTokenStore();

  @override
  Future<String?> readAccess() async => _access;

  @override
  Future<String?> readRefresh() async => _refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

class _StubAuthRepository implements AuthRepository {
  @override
  Future<(User?, Failure?)> login({
    required String email,
    required String password,
  }) async =>
      (const User(accessToken: 'token-1', refreshToken: 'refresh-1'), null);

  @override
  Future<String> refresh(String refreshToken) async => 'token-2';
}

class _CountingAdapter implements HttpClientAdapter {
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    return ResponseBody.fromString(
      jsonEncode({'ok': true, 'hits': requestCount}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = {};

  _MemorySecureStorage();

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }
}

void main() {
  group('Optimasi Performa & Lifecycle', () {
    test('NotesRepositoryImpl memanfaatkan search cache tanpa merusak salinan',
        () async {
      final repo = NotesRepositoryImpl();

      final (first, err1) = await repo.searchNotesByTitle('Flutter');
      expect(err1, isNull);
      expect(first, isNotNull);
      expect(first!.length, 1);

      // Mutasi hasil pertama tidak boleh memengaruhi cache internal
      first.clear();

      final (second, err2) = await repo.searchNotesByTitle('flutter');
      expect(err2, isNull);
      expect(second, isNotNull);
      expect(second!.length, 1);
    });

    test('Dio _GetResponseCacheInterceptor meng-cache GET 200 dalam TTL',
        () async {
      final dio = buildApiClient(_MemoryTokenStore(), _StubAuthRepository());
      final adapter = _CountingAdapter();
      dio.httpClientAdapter = adapter;

      final res1 = await dio.get<Map<String, dynamic>>('/announcements');
      final res2 = await dio.get<Map<String, dynamic>>('/announcements');
      expect(res1.data?['hits'], 1);
      expect(res2.data?['hits'], 1);
      expect(adapter.requestCount, 1);

      // skipCache memaksa request jaringan baru
      final res3 = await dio.get<Map<String, dynamic>>(
        '/announcements',
        options: Options(extra: {'skipCache': true}),
      );
      expect(res3.data?['hits'], 2);
      expect(adapter.requestCount, 2);
    });

    testWidgets('NotesPage melakukan filter dan dispose controller dengan bersih',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: NotesPage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('notes_search_field')), 'Riverpod');
      await tester.pumpAndSettle();
      expect(find.text('Belajar Riverpod StateNotifier'), findsOneWidget);

      // Lepas widget dari tree untuk memverifikasi dispose() bersih
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets(
        'ChatScreen membatalkan timer _StreamingText dengan bersih saat dispose',
        (tester) async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text':
                          'Respons panjang untuk menguji pembatalan timer streaming saat halaman ditutup.'
                    },
                  ],
                },
              },
            ],
          }),
          200,
        ),
      );
      final service = AiService(storage: _MemorySecureStorage(), client: client);
      await service.saveApiKey('dummy-key');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [aiServiceProvider.overrideWithValue(service)],
          child: const MaterialApp(home: ChatScreen()),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Info kampus');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      // Tutup ChatScreen di tengah animasi streaming
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });
}

