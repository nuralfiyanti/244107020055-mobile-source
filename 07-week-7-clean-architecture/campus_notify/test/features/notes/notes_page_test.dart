import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/presentation/pages/notes_page.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const ProviderScope(
      child: MaterialApp(
        home: NotesPage(),
      ),
    );
  }

  group('NotesPage Widget Tests', () {
    testWidgets(
      'Kondisi Awal: Menampilkan daftar catatan saat halaman pertama kali dibuka',
      (WidgetTester tester) async {
        // Render UI
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Verifikasi elemen Search Bar dan ListView tampil
        expect(find.byKey(const Key('notes_search_field')), findsOneWidget);
        expect(find.byKey(const Key('notes_list_view')), findsOneWidget);

        // Verifikasi salah satu judul catatan awal muncul
        expect(find.text('Tugas Mobile Programming'), findsOneWidget);

        // Pastikan Empty State TIDAK muncul pada inisialisasi awal
        expect(find.byKey(const Key('notes_empty_state')), findsNothing);
      },
    );

    testWidgets(
      'Kondisi Empty State: Menampilkan pesan kosong saat query tidak cocok',
      (WidgetTester tester) async {
        // Render UI
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Cari Search Bar dan ketikkan kata kunci yang tidak ada di data
        final searchField = find.byKey(const Key('notes_search_field'));
        await tester.enterText(searchField, 'flutter-tidak-ada-123');

        // Tunggu hingga event onChanged selesai memproses pencarian
        await tester.pumpAndSettle();

        // Verifikasi bahwa Empty State muncul dengan teks yang sesuai
        expect(find.byKey(const Key('notes_empty_state')), findsOneWidget);
        expect(find.text('Catatan tidak ditemukan'), findsOneWidget);

        // Pastikan ListView catatan sudah tidak lagi ditampilkan
        expect(find.byKey(const Key('notes_list_view')), findsNothing);
      },
    );
  });
}

