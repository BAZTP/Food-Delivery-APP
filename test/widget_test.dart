import 'package:flutter_test/flutter_test.dart';
import 'package:quickfood/main.dart';

void main() {
  testWidgets('QuickFood app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuickFoodApp());
    await tester.pumpAndSettle();

    // Verify that the bottom navigation destinations appear
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);
    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Categorías'), findsOneWidget);
  });
}
