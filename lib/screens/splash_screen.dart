import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controller untuk animasi fade-in keseluruhan konten
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Controller untuk animasi scale logo
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Controller untuk animasi slide-up teks
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Controller untuk animasi progress bar
  late AnimationController _progressController;

  late Timer _navigationTimer;

  @override
  void initState() {
    super.initState();

    // ── Sembunyikan status bar ──────────────────────────────────────────────
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // ── Fade-in overlay dan logo ───────────────────────────────────────────
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // ── Scale bounce logo ─────────────────────────────────────────────────
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // ── Slide-up teks ─────────────────────────────────────────────────────
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // ── Progress bar 3 detik ──────────────────────────────────────────────
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // ── Jalankan animasi secara berurutan ─────────────────────────────────
    _startAnimations();

    // ── Auto navigate setelah 3 detik ─────────────────────────────────────
    _navigationTimer = Timer(const Duration(milliseconds: 3200), _goToHome);
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    _slideController.forward();
    _progressController.forward();
  }

  void _goToHome() {
    if (!mounted) return;
    // Pulihkan status bar sebelum navigasi
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  void dispose() {
    _navigationTimer.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ───────────────────────────────────────────
          Image.network(
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836'
            '?auto=format&fit=crop&q=80&w=1200',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(color: const Color(0xFF1A0A00));
            },
            errorBuilder: (context, error, stackTrace) =>
                Container(color: const Color(0xFF1A0A00)),
          ),

          // ── Dark gradient overlay ──────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC000000), // 80% hitam di atas
                    Color(0xB3000000), // 70% hitam di tengah
                    Color(0xE6000000), // 90% hitam di bawah
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ── Konten utama ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // ── Logo lingkaran ─────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withAlpha(120),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withAlpha(80),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        size: 56,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Nama & tagline ──────────────────────────────────────
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Nama aplikasi
                        const Text(
                          'RecipeApp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Ornamen garis
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.orange.withAlpha(180),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 30,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.orange.withAlpha(180),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Tagline
                        Text(
                          'Temukan Resep Masakan Terbaik',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Progress bar & teks bawah ───────────────────────────
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          // Progress bar
                          AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _progressController.value,
                                  backgroundColor:
                                      Colors.white.withAlpha(40),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Colors.orange,
                                  ),
                                  minHeight: 3,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat pengalaman memasak terbaik...',
                            style: TextStyle(
                              color: Colors.white.withAlpha(120),
                              fontSize: 12,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
