import 'package:flutter_test/flutter_test.dart';
import 'package:culinary_pro/main.dart';
import 'package:provider/provider.dart';
import 'package:culinary_pro/providers/recipe_provider.dart';
import 'package:culinary_pro/providers/theme_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RecipeProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const RecipeApp(),
      ),
    );

    // Verify that our app shows the title.
    expect(find.text('CulinaryPro'), findsOneWidget);
  });
}
