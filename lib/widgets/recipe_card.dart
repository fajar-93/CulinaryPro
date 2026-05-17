import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/favorite_provider.dart';
import '../providers/bookmark_provider.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final String heroPrefix;

  const RecipeCard({super.key, required this.recipe, this.heroPrefix = 'card'});

  @override
  Widget build(BuildContext context) {
    final isFav = context.select<FavoriteProvider, bool>(
      (prov) => prov.isFavorite(recipe.id),
    );
    final isBookmarked = context.select<BookmarkProvider, bool>(
      (prov) => prov.isBookmarked(recipe.id),
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/detail',
          arguments: {'id': recipe.id, 'prefix': heroPrefix},
        );
      },
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image Section ───────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: '${heroPrefix}_${recipe.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: _buildImage(recipe.imageUrl),
                    ),
                  ),

                  // Tombol Favorit
                  Positioned(
                    top: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: () {
                        context.read<FavoriteProvider>().toggleFavorite(recipe);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isFav
                              ? Colors.red.withAlpha(230)
                              : Theme.of(context).brightness == Brightness.dark 
                                  ? const Color.fromRGBO(50, 50, 50, 0.9)
                                  : const Color.fromRGBO(255, 255, 255, 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isFav
                                  ? Colors.red.withAlpha(80)
                                  : Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.white : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Tombol Bookmark
                  Positioned(
                    top: 15,
                    right: 65,
                    child: GestureDetector(
                      onTap: () {
                        context.read<BookmarkProvider>().toggleBookmark(recipe);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isBookmarked
                              ? Colors.blue.withAlpha(230)
                              : Theme.of(context).brightness == Brightness.dark 
                                  ? const Color.fromRGBO(50, 50, 50, 0.9)
                                  : const Color.fromRGBO(255, 255, 255, 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isBookmarked
                                  ? Colors.blue.withAlpha(80)
                                  : Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? Colors.white : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Badge durasi
                  Positioned(
                    bottom: 15,
                    left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.durationMinutes} min',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Info Section ─────────────────────────────────────────────
            SizedBox(
              height: 80,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.bar_chart,
                            size: 15, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          recipe.difficulty,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Lihat Resep',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Colors.orange, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper untuk menangani gambar local asset atau network URL
  Widget _buildImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
    );
  }
}
