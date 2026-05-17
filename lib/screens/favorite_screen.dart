import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.watch<FavoriteProvider>();
    final recipeProvider = context.watch<RecipeProvider>();
    final favoriteRecipes = favoriteProvider.getFavoriteRecipes(
      recipeProvider.allRecipes,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${favoriteProvider.favoriteCount} resep tersimpan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              'Resep Favorit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          if (favoriteProvider.favoriteCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                onPressed: () => _confirmClearAll(context, favoriteProvider),
                icon: const Icon(Icons.delete_sweep_outlined,
                    color: Colors.red, size: 20),
                label: const Text(
                  'Hapus Semua',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: favoriteRecipes.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                itemCount: favoriteRecipes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RecipeCard(recipe: favoriteRecipes[index]),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.withAlpha(30) : Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 60,
              color: Colors.orange[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Favorit',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap ikon ❤️ pada resep\nuntuk menyimpannya di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.explore_outlined),
            label: const Text('Jelajahi Resep'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(
      BuildContext context, FavoriteProvider favoriteProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Hapus Semua Favorit?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Semua resep favorit akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              favoriteProvider.clearFavorites();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua favorit telah dihapus'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }
}
