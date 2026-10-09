import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week5_offline_notes/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsPage tampil dengan ProviderScope', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Render awal
    await tester.pump();

    // Tunggu async (SharedPreferences)
    await tester.pump(const Duration(milliseconds: 500));

    // Cek AppBar
    expect(find.text('Pengaturan'), findsOneWidget);
  });
}