import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/main.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/providers/recipe_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ],
        child: const RecipeApp(),
      ),
    );

    // Verify that our app shows the title.
    expect(find.text('RecipeApp'), findsOneWidget);
  });
}
