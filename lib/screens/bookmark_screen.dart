import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final recipeProvider = context.watch<RecipeProvider>();
    final bookmarkedRecipes = bookmarkProvider.getBookmarkedRecipes(
      recipeProvider.allRecipes,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${bookmarkProvider.bookmarkCount} resep disimpan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                  ),
            ),
            Text(
              'Bookmark',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
                  ),
            ),
          ],
        ),
        actions: [
          if (bookmarkProvider.bookmarkCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                onPressed: () => _confirmClearAll(context, bookmarkProvider),
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
        child: bookmarkedRecipes.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                itemCount: bookmarkedRecipes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RecipeCard(
                      recipe: bookmarkedRecipes[index],
                      heroPrefix: 'bookmark',
                    ),
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
              color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.withAlpha(30) : Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 60,
              color: Colors.blue[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Bookmark',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap ikon Bookmark pada resep\nuntuk membacanya nanti',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[500],
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(
      BuildContext context, BookmarkProvider bookmarkProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Hapus Semua Bookmark?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Semua resep bookmark akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              bookmarkProvider.clearBookmarks();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua bookmark telah dihapus'),
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
