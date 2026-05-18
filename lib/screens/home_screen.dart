import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/recipe_card.dart';
import 'favorite_screen.dart';
import 'category_screen.dart';
import 'bookmark_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang ditampilkan oleh bottom navigation.
  // IndexedStack menjaga state tiap tab tetap hidup.
  static const List<Widget> _pages = [
    _HomeTab(),
    FavoriteScreen(),
    BookmarkScreen(),
    CategoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final favCount =
        context.select<FavoriteProvider, int>((p) => p.favoriteCount);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: favCount > 0,
                label: Text('$favCount'),
                backgroundColor: Colors.red,
                child: const Icon(Icons.favorite_rounded),
              ),
              label: 'Favorit',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_rounded),
              label: 'Bookmark',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Kategori',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Beranda ─────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String _selectedMenu = 'Semua';

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();
    final allRecipes = recipeProvider.recipes;

    String getSelectedCategoryId() {
      switch (_selectedMenu) {
        case 'Sarapan': return 'sarapan';
        case 'Makan Siang': return 'makan_siang';
        case 'Makan Malam': return 'makan_malam';
        case 'Camilan': return 'camilan';
        default: return 'all';
      }
    }

    final categoryId = getSelectedCategoryId();
    final recipes = categoryId == 'all' 
        ? allRecipes 
        : allRecipes.where((r) => r.category == categoryId).toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Foodie!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[600],
                  ),
            ),
            Text(
              'Mau masak apa hari ini?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.orange,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Belum ada notifikasi baru')),
                );
              },
              child: CircleAvatar(
                backgroundColor: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.orange.withAlpha(50) 
                    : Colors.orange[50],
                child: const Icon(Icons.notifications_outlined,
                    color: Colors.orange),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[800] 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  onChanged: recipeProvider.updateSearchQuery,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari resep favoritmu...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            // Categories (static)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  _buildCategoryItem(context, 'Semua', _selectedMenu == 'Semua'),
                  _buildCategoryItem(context, 'Sarapan', _selectedMenu == 'Sarapan'),
                  _buildCategoryItem(context, 'Makan Siang', _selectedMenu == 'Makan Siang'),
                  _buildCategoryItem(context, 'Makan Malam', _selectedMenu == 'Makan Malam'),
                  _buildCategoryItem(context, 'Camilan', _selectedMenu == 'Camilan'),
                ],
              ),
            ),

            // Recipe List Title
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resep Terbaru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Lihat Semua',
                        style: TextStyle(color: Colors.orange)),
                  ),
                ],
              ),
            ),

            // Recipe List
            Expanded(
              child: recipes.isEmpty
                  ? const Center(child: Text('Resep tidak ditemukan'))
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RecipeCard(recipe: recipes[index], heroPrefix: 'home'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMenu = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.orange 
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

