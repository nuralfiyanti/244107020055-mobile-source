import 'package:flutter_test/flutter_test.dart';
import 'package:week3_navigation/main.dart';

void main() {
  testWidgets('membuka halaman detail dari Home', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Item 1'), findsOneWidget);

    await tester.tap(find.text('Item 1'));
    await tester.pumpAndSettle();

    expect(find.text('Detail 1'), findsOneWidget);
    expect(find.text('Anda membuka item dengan id: 1'), findsOneWidget);
  });
}