import 'package:flutter_test/flutter_test.dart';
import 'package:genshinimport/main.dart';

void main() {
  testWidgets('Login page tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Genshin Import'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
