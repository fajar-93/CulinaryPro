import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();
    final recipes = recipeProvider.recipes;
    final size = MediaQuery.of(context).size;

    // Responsive column count
    int crossAxisCount = 2;
    if (size.width > 600) crossAxisCount = 3;
    if (size.width > 900) crossAxisCount = 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RecipeApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // Navigation to favorites or filter can be added here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Cari resep...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                recipeProvider.updateSearchQuery(value);
              },
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(Colors.grey[200]),
            ),
          ),
          Expanded(
            child: recipes.isEmpty
                ? const Center(child: Text('Resep tidak ditemukan'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return RecipeCard(recipe: recipes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
