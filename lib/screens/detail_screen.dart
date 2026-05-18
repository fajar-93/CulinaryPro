import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/recipe_video_player.dart';
import '../models/recipe_model.dart';
import '../services/translation_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isVideoPlaying = false;
  final TranslationService _translationService = TranslationService();
  bool _isTranslated = false;
  bool _isTranslating = false;
  Recipe? _translatedRecipe;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    String recipeId;
    String heroPrefix = 'card';
    
    if (args is Map<String, dynamic>) {
      recipeId = args['id'] as String;
      heroPrefix = args['prefix'] as String;
    } else {
      recipeId = args as String;
    }

    final recipe = context.read<RecipeProvider>().findById(recipeId);
    final activeRecipe = _isTranslated && _translatedRecipe != null ? _translatedRecipe! : recipe;

    // Selector memastikan hanya ikon yang rebuild saat state berubah.
    final isFav = context.select<FavoriteProvider, bool>(
      (prov) => prov.isFavorite(recipeId),
    );
    final isBookmarked = context.select<BookmarkProvider, bool>(
      (prov) => prov.isBookmarked(recipeId),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Elegant Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).brightness == Brightness.dark 
                    ? const Color.fromRGBO(50, 50, 50, 0.9)
                    : const Color.fromRGBO(255, 255, 255, 0.9),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, 
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              // Tombol Terjemahan
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CircleAvatar(
                  backgroundColor: _isTranslated
                      ? Colors.orange
                      : Theme.of(context).brightness == Brightness.dark 
                          ? const Color.fromRGBO(50, 50, 50, 0.9)
                          : const Color.fromRGBO(255, 255, 255, 0.9),
                  child: _isTranslating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.g_translate_rounded,
                            color: _isTranslated
                                ? Colors.white
                                : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                          ),
                          onPressed: () async {
                            if (_isTranslated) {
                              setState(() {
                                _isTranslated = false;
                              });
                            } else {
                              if (_translatedRecipe != null) {
                                setState(() {
                                  _isTranslated = true;
                                });
                              } else {
                                setState(() {
                                  _isTranslating = true;
                                });
                                try {
                                  final translated = await _translationService.translateRecipe(recipe);
                                  setState(() {
                                    _translatedRecipe = translated;
                                    _isTranslated = true;
                                    _isTranslating = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    _isTranslating = false;
                                  });
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString().replaceAll('Exception: ', '')),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CircleAvatar(
                  backgroundColor: isBookmarked
                      ? Colors.blue.withAlpha(230)
                      : Theme.of(context).brightness == Brightness.dark 
                          ? const Color.fromRGBO(50, 50, 50, 0.9)
                          : const Color.fromRGBO(255, 255, 255, 0.9),
                  child: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        key: ValueKey<bool>(isBookmarked),
                        color: isBookmarked ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                      ),
                    ),
                    onPressed: () {
                      context.read<BookmarkProvider>().toggleBookmark(recipe);

                      final message =
                          isBookmarked ? 'Dihapus dari bookmark' : 'Disimpan ke bookmark';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor:
                              isBookmarked ? Colors.grey[700] : Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: isFav
                      ? Colors.red.withAlpha(230)
                      : Theme.of(context).brightness == Brightness.dark 
                          ? const Color.fromRGBO(50, 50, 50, 0.9)
                          : const Color.fromRGBO(255, 255, 255, 0.9),
                  child: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey<bool>(isFav),
                        color: isFav ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                      ),
                    ),
                    onPressed: () {
                      context.read<FavoriteProvider>().toggleFavorite(recipe);

                      final message =
                          isFav ? 'Dihapus dari favorit' : 'Ditambahkan ke favorit';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor:
                              isFav ? Colors.grey[700] : Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _isVideoPlaying && recipe.youtubeId != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: kToolbarHeight + 24), // Offset for AppBar & StatusBar
                      child: RecipeVideoPlayer(youtubeId: recipe.youtubeId!),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: '${heroPrefix}_${recipe.id}',
                          child: Image.network(
                            recipe.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey, size: 64),
                            ),
                          ),
                        ),
                        if (recipe.youtubeId != null)
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isVideoPlaying = true;
                                });
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(150),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),

          // ─── Content Section ─────────────────────────────────────────────
          SliverToBoxAdapter(
              child: Container(
                transform: Matrix4.translationValues(0, -30, 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Basic Info
                    Text(
                      activeRecipe.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildBadge(context, Icons.timer_outlined,
                            '${activeRecipe.durationMinutes} Menit'),
                        const SizedBox(width: 15),
                        _buildBadge(context, Icons.bar_chart, activeRecipe.difficulty),
                      ],
                    ),

                    const SizedBox(height: 30),
                    // Description
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      activeRecipe.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),
                    // Ingredients
                    const Text(
                      'Bahan-bahan',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: activeRecipe.ingredients.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.withAlpha(30) : Colors.orange[50],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  activeRecipe.ingredients[index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                    // Instructions
                    const Text(
                      'Langkah Memasak',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: activeRecipe.instructions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  activeRecipe.instructions[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.orange),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
