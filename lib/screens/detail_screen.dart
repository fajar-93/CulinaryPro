import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../providers/recipe_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/recipe_video_player.dart';
import '../models/recipe_model.dart';
import '../services/translation_service.dart';
import '../providers/comment_provider.dart';
import '../models/comment_model.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/custom_video_player.dart';

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

  Future<void> _confirmDelete(BuildContext context, Recipe recipe) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.delete_outline, color: Colors.red, size: 32),
        ),
        title: const Text(
          'Hapus Resep',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus resep ini?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                recipe.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogCtx, false),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogCtx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<RecipeProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final success = await provider.deleteRecipe(
      recipeId: recipe.id,
      imageUrl: recipe.imageUrl,
      ownerUserId: recipe.userId ?? '',
      currentUserId: currentUser.uid,
    );

    if (!context.mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Resep berhasil dihapus'),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      navigator.pop(); // Kembali ke halaman sebelumnya
    } else {
      final errMsg = provider.deleteErrorMessage ?? 'Gagal menghapus resep.';
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(errMsg)),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Data resep tidak ditemukan (sesi kedaluwarsa).'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                child: const Text('Kembali ke Beranda'),
              )
            ],
          ),
        ),
      );
    }

    String recipeId;
    String heroPrefix = 'card';
    
    if (args is Map<String, dynamic>) {
      recipeId = args['id'] as String;
      heroPrefix = args['prefix'] as String;
    } else {
      recipeId = args.toString();
    }

    Recipe? recipe;
    try {
      recipe = context.read<RecipeProvider>().findById(recipeId);
    } catch (_) {
      recipe = null;
    }

    if (recipe == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Resep tidak ditemukan atau data belum dimuat.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      );
    }

    // Deklarasikan sebagai non-nullable setelah null check
    final Recipe activeRecipeData = recipe;

    final activeRecipe = _isTranslated && _translatedRecipe != null
        ? _translatedRecipe!
        : activeRecipeData;

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
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              // ── Tombol Hapus (hanya untuk pemilik resep) ──
              Builder(
                builder: (ctx) {
                  final currentUser = FirebaseAuth.instance.currentUser;
                  final isOwner = currentUser != null &&
                      activeRecipeData.userId != null &&
                      activeRecipeData.userId == currentUser.uid;
                  if (!isOwner) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.red.withAlpha(220),
                      child: ctx.select<RecipeProvider, bool>(
                                (p) => p.isDeleting)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                              ),
                              tooltip: 'Hapus Resep',
                              onPressed: () =>
                                  _confirmDelete(context, activeRecipeData),
                            ),
                    ),
                  );
                },
              ),
              // ── Tombol Terjemahan ──
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.orange,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.g_translate_rounded,
                            color: _isTranslated
                                ? Colors.white
                                : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black),
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
                                  final translated = await _translationService
                                      .translateRecipe(recipe!);
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
                                      content: Text(
                                        e.toString().replaceAll(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
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
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        key: ValueKey<bool>(isBookmarked),
                        color: isBookmarked
                            ? Colors.white
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black),
                      ),
                    ),
                    onPressed: () {
                      context.read<BookmarkProvider>().toggleBookmark(recipe!);

                      final message = isBookmarked
                          ? 'Dihapus dari bookmark'
                          : 'Disimpan ke bookmark';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: isBookmarked
                              ? Colors.grey[700]
                              : Colors.blue,
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
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey<bool>(isFav),
                        color: isFav
                            ? Colors.white
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black),
                      ),
                    ),
                    onPressed: () {
                      context.read<FavoriteProvider>().toggleFavorite(recipe!);

                      final message = isFav
                          ? 'Dihapus dari Suka'
                          : 'Ditambahkan ke Suka';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: isFav
                              ? Colors.grey[700]
                              : Colors.orange,
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
                      padding: const EdgeInsets.only(
                        top: kToolbarHeight + 24,
                      ), // Offset for AppBar & StatusBar
                      child: RecipeVideoPlayer(youtubeId: recipe.youtubeId!),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: '${heroPrefix}_${recipe.id}',
                          child: recipe.imageUrl.startsWith('assets/')
                              ? Image.asset(
                                  recipe.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 64,
                                        ),
                                      ),
                                )
                              : Image.network(
                                  recipe.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 64,
                                        ),
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
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Basic Info
                    Text(
                      activeRecipe.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildBadge(
                          context,
                          Icons.timer_outlined,
                          '${activeRecipe.durationMinutes} Menit',
                        ),
                        const SizedBox(width: 15),
                        _buildBadge(
                          context,
                          Icons.bar_chart,
                          activeRecipe.difficulty,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    // Description
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      activeRecipe.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),
                    // Ingredients
                    const Text(
                      'Bahan-bahan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.orange.withAlpha(30)
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.orange,
                                size: 20,
                              ),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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

                    const SizedBox(height: 30),
                    // Video Tutorial
                    const Text(
                      'Video Tutorial',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (activeRecipe.videoUrl != null && activeRecipe.videoUrl!.isNotEmpty)
                      CustomVideoPlayer(videoUrl: activeRecipe.videoUrl!)
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[850]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.videocam_off, color: Colors.grey, size: 30),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                'Tidak ada video tutorial untuk resep ini.',
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 30),
                    // Ulasan & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ulasan & Rating',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25),
                                ),
                              ),
                              builder: (context) =>
                                  CommentSheet(recipeId: recipeId),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 42),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.rate_review, size: 18),
                              SizedBox(width: 8),
                              Text('Beri Ulasan'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    StreamBuilder<List<Comment>>(
                      stream: context.read<CommentProvider>().getCommentsStream(
                        recipeId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Terjadi kesalahan: ${snapshot.error}'),
                          );
                        }

                        final comments = snapshot.data ?? [];
                        if (comments.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Text(
                                'Belum ada ulasan. Jadilah yang pertama!',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: comments.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            final date = comment.createdAt;
                            final dateString =
                                "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

                            return Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[850]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                ),
                                boxShadow: [
                                  if (Theme.of(context).brightness ==
                                      Brightness.light)
                                    BoxShadow(
                                      color: Colors.grey.withAlpha(20),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          comment.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        dateString,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < comment.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    comment.text,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          },
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
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.orange),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
