import 'package:flutter_test/flutter_test.dart';
import 'package:inv_telas/main.dart';

void main() {
  testWidgets('Firebase status test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Verificación Firebase'), findsOneWidget);
  });
}
