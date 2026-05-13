import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/category_provider.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'services/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: const RecipeApp(),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecipeApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/detail': (context) => const DetailScreen(),
      },
    );
  }
}
