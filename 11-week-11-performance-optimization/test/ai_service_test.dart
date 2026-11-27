import 'dart:convert';

import 'package:campus_notify/ai/ai_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = {};

  _FakeSecureStorage();

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

http.Response _geminiOkResponse(String text) => http.Response(
      jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': text},
              ],
            },
          },
        ],
      }),
      200,
      headers: {'content-type': 'application/json'},
    );

void main() {
  group('AiService', () {
    late _FakeSecureStorage storage;

    setUp(() {
      storage = _FakeSecureStorage();
    });

    group('Validasi privasi input sensitif', () {
      test('menolak input yang mengandung NIK 16 digit', () async {
        final service = AiService(storage: storage);
        expect(
          () => service.ask('NIK saya 3507123456789012 tolong cek'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('NIK'),
            ),
          ),
        );
      });

      test('menolak input yang mengandung nomor telepon 08... atau +62...',
          () async {
        final service = AiService(storage: storage);
        await expectLater(
          service.ask('Hubungi saya di 081234567890'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('nomor telepon'),
            ),
          ),
        );
        await expectLater(
          service.ask('Nomor WA +6281234567890'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('nomor telepon'),
            ),
          ),
        );
      });

      test('menolak input yang mengandung alamat email', () async {
        final service = AiService(storage: storage);
        expect(
          () => service.ask('Kirim ke mahasiswa@kampus.ac.id'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('email'),
            ),
          ),
        );
      });

      test('menolak kata kunci sensitif password dan alamat', () async {
        final service = AiService(storage: storage);
        await expectLater(
          service.ask('Apa password portal saya?'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('data sensitif'),
            ),
          ),
        );
        await expectLater(
          service.ask('Dimana alamat rumah dosen?'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('data sensitif'),
            ),
          ),
        );
      });
    });

    group('API Key & Secure Storage', () {
      test('menyimpan dan membaca API key via FlutterSecureStorage', () async {
        final service = AiService(storage: storage);
        expect(await service.getApiKey(), isNull);

        await service.saveApiKey('dummy-api-key-123');
        expect(await service.getApiKey(), 'dummy-api-key-123');
      });

      test('mengembalikan pesan setup jika API key kosong', () async {
        var httpCalled = false;
        final client = MockClient((_) async {
          httpCalled = true;
          return _geminiOkResponse('ok');
        });
        final service = AiService(storage: storage, client: client);

        final result = await service.ask('Jadwal kuliah hari ini?');
        expect(result, contains('API Key belum diatur'));
        expect(httpCalled, isFalse);
      });
    });

    group('Cache lokal, Rate Limit, dan Fallback', () {
      test('memanfaatkan cache lokal untuk pertanyaan yang sama', () async {
        var callCount = 0;
        final client = MockClient((_) async {
          callCount++;
          return _geminiOkResponse('Jadwal tersedia di portal akademik.');
        });
        final service = AiService(storage: storage, client: client);
        await service.saveApiKey('dummy-key');

        final first = await service.ask('Jadwal kuliah hari ini?');
        final second = await service.ask('  jadwal kuliah hari ini?  ');

        expect(first, 'Jadwal tersedia di portal akademik.');
        expect(second, first);
        expect(callCount, 1);
        expect(service.requestCount, 1);
      });

      test('membatasi rate limit maksimal 20 request per sesi', () async {
        var callCount = 0;
        final client = MockClient((_) async {
          callCount++;
          return _geminiOkResponse('Jawaban #$callCount');
        });
        final service = AiService(storage: storage, client: client);
        await service.saveApiKey('dummy-key');

        for (var i = 1; i <= 20; i++) {
          final res = await service.ask('Pertanyaan ke-$i');
          expect(res, 'Jawaban #$i');
        }
        expect(service.requestCount, 20);

        final overLimit = await service.ask('Pertanyaan ke-21');
        expect(overLimit, contains('Batas maksimal pertanyaan sesi ini'));
        expect(callCount, 20);
      });

      test('mengembalikan fallback saat HTTP response error (500)', () async {
        final client = MockClient(
          (_) async => http.Response('Internal Server Error', 500),
        );
        final service = AiService(storage: storage, client: client);
        await service.saveApiKey('dummy-key');

        final result = await service.ask('Info KRS?');
        expect(result, contains('Maaf, layanan AI sementara tidak tersedia'));
        expect(result, contains('Error 500'));
      });

      test('mengembalikan fallback saat terjadi exception jaringan', () async {
        final client = MockClient((_) async {
          throw Exception('Network timeout');
        });
        final service = AiService(storage: storage, client: client);
        await service.saveApiKey('dummy-key');

        final result = await service.ask('Info UTS?');
        expect(
          result,
          'Maaf, layanan AI sementara tidak tersedia. '
          'Untuk informasi jadwal, hubungi akademik kampus atau cek portal mahasiswa.',
        );
      });
    });
  });
}

