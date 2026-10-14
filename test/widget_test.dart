import 'package:flutter_test/flutter_test.dart';
import 'package:al_quran/main.dart';

void main() {
  testWidgets('shows Arabic app home', (tester) async {
    await tester.pumpWidget(const QuranApp());
    await tester.pumpAndSettle();
    expect(find.text('القرآن الكريم'), findsWidgets);
    expect(find.text('ابدأ القراءة'), findsOneWidget);
  });
}
