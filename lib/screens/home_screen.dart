import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/recipe_card.dart';
import 'favorite_screen.dart';
import 'category_screen.dart';

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
    CategoryScreen(),
    _PlaceholderTab(icon: Icons.person_rounded, label: 'Profil'),
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
          backgroundColor: Colors.white,
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
              icon: Icon(Icons.grid_view_rounded),
              label: 'Kategori',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Beranda ─────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();
    final recipes = recipeProvider.recipes;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Foodie!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
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
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.orange[50],
              child: const Icon(Icons.notifications_outlined,
                  color: Colors.orange),
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
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  onChanged: recipeProvider.updateSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Cari resep favoritmu...',
                    prefixIcon: Icon(Icons.search, color: Colors.orange),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
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
                  _buildCategoryItem('Semua', true),
                  _buildCategoryItem('Sarapan', false),
                  _buildCategoryItem('Makan Siang', false),
                  _buildCategoryItem('Makan Malam', false),
                  _buildCategoryItem('Camilan', false),
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
                          child: RecipeCard(recipe: recipes[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight:
              isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

// ─── Placeholder Tab ──────────────────────────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.orange[200]),
            const SizedBox(height: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Segera hadir',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
