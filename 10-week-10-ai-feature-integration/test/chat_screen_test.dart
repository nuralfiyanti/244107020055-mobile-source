import 'dart:async';
import 'dart:convert';

import 'package:campus_notify/ai/ai_service.dart';
import 'package:campus_notify/features/chat_screen.dart';
import 'package:campus_notify/providers/ai_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _InMemoryStorage extends FlutterSecureStorage {
  final Map<String, String> _data = {};

  _InMemoryStorage();

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
      _data[key];

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
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }
}

void main() {
  Widget buildTestApp(AiService service) {
    return ProviderScope(
      overrides: [
        aiServiceProvider.overrideWithValue(service),
      ],
      child: const MaterialApp(
        home: ChatScreen(),
      ),
    );
  }

  group('ChatScreen Widget Test', () {
    testWidgets('merender halaman chat, banner keamanan, dan empty state',
        (tester) async {
      final service = AiService(storage: _InMemoryStorage());
      await tester.pumpWidget(buildTestApp(service));

      expect(find.text('Asisten Kampus AI'), findsOneWidget);
      expect(
        find.text(
          'Jangan kirim NIK, nomor telepon, email, atau data sensitif ke AI.',
        ),
        findsOneWidget,
      );
      expect(find.text('Atur API Key terlebih dahulu'), findsOneWidget);
    });

    testWidgets(
        'mengirim pesan menampilkan indikator loading lalu streaming respons',
        (tester) async {
      final completer = Completer<http.Response>();
      final client = MockClient((_) => completer.future);
      final storage = _InMemoryStorage();
      final service = AiService(storage: storage, client: client);
      await service.saveApiKey('dummy-key');

      await tester.pumpWidget(buildTestApp(service));

      await tester.enterText(
        find.byType(TextField),
        'Kapan jadwal UTS?',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Pesan user dan indikator loading tampil
      expect(find.text('Kapan jadwal UTS?'), findsOneWidget);
      expect(find.text('Asisten sedang menjawab...'), findsOneWidget);

      // Selesaikan respons HTTP
      completer.complete(
        http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'UTS dilaksanakan minggu ke-8.'},
                  ],
                },
              },
            ],
          }),
          200,
        ),
      );

      // Pump bertahap agar animasi FadeTransition + _StreamingText selesai
      await tester.pump();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 25));
      }

      expect(find.text('Asisten sedang menjawab...'), findsNothing);
      expect(find.text('UTS dilaksanakan minggu ke-8.'), findsOneWidget);
    });

    testWidgets(
        'menampilkan AlertDialog error dan menambahkan fallback offline',
        (tester) async {
      final service = AiService(storage: _InMemoryStorage());
      await tester.pumpWidget(buildTestApp(service));

      // Kirim input sensitif (NIK) agar AiService melempar Exception
      await tester.enterText(
        find.byType(TextField),
        'NIK saya 3507123456789012',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pump();

      // AlertDialog error muncul
      expect(find.text('Layanan AI Sibuk'), findsOneWidget);
      expect(find.text('Gunakan Jawaban Offline'), findsOneWidget);

      // Tap tombol fallback
      await tester.tap(find.text('Gunakan Jawaban Offline'));
      await tester.pump();
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 25));
      }

      expect(find.text('Layanan AI Sibuk'), findsNothing);
      expect(
        find.textContaining('Maaf, layanan AI sementara tidak tersedia.'),
        findsOneWidget,
      );
    });
  });
}

