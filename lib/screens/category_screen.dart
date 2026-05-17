import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jelajahi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              'Kategori Resep',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
                  ),
            ),
          ],
        ),
      ),
      body: const _CategoryBody(),
    );
  }
}

// ─── Body utama: GridView kategori + list resep ───────────────────────────────

class _CategoryBody extends StatelessWidget {
  const _CategoryBody();

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final selectedId = categoryProvider.selectedCategoryId;
    final categories = categoryProvider.categories;

    final allRecipes = context.watch<RecipeProvider>().allRecipes;

    // Filter resep: "all" tampilkan semua, selain itu filter by category id
    final filteredRecipes = selectedId == 'all'
        ? allRecipes
        : allRecipes.where((r) => r.category == selectedId).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Header dekoratif ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _CategoryHeader(selectedCategory: categoryProvider.selectedCategory),
        ),

        // ── GridView Kategori ────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                final isSelected = category.id == selectedId;
                return _CategoryCard(
                  category: category,
                  isSelected: isSelected,
                  onTap: () => categoryProvider.selectCategory(category.id),
                );
              },
              childCount: categories.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
          ),
        ),

        // ── Divider & judul resep ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryProvider.selectedCategory.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
                      ),
                    ),
                    Text(
                      '${filteredRecipes.length} resep ditemukan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                if (selectedId != 'all')
                  TextButton.icon(
                    onPressed: () => categoryProvider.resetCategory(),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Daftar resep berdasarkan kategori ────────────────────────────────
        filteredRecipes.isEmpty
            ? SliverFillRemaining(child: _EmptyCategory())
            : SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RecipeCard(recipe: filteredRecipes[index], heroPrefix: 'category'),
                    ),
                    childCount: filteredRecipes.length,
                  ),
                ),
              ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ─── Header dekoratif ─────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  final RecipeCategory selectedCategory;

  const _CategoryHeader({required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            selectedCategory.iconColor.withAlpha(200),
            selectedCategory.iconColor.withAlpha(140),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: selectedCategory.iconColor.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              selectedCategory.icon,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCategory.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pilih kategori untuk melihat resep',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card kategori satu item ──────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final RecipeCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? category.iconColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? category.iconColor : Colors.grey.withAlpha(30),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? category.iconColor.withAlpha(80)
                  : Colors.black.withAlpha(10),
              blurRadius: isSelected ? 14 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withAlpha(40)
                    : category.color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                size: 24,
                color: isSelected ? Colors.white : category.iconColor,
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected 
                      ? Colors.white 
                      : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.orange[300],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Resep',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resep untuk kategori ini\nbelum tersedia',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
