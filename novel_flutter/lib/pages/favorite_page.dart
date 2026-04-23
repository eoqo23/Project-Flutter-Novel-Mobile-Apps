import 'package:flutter/material.dart';
import 'package:novel_flutter/pages/bookmark_page.dart';
import '../models/novel.dart';
import '../services/api_services.dart';
import 'detail_novel_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Novel> favorites = [];
  bool isLoading = true;

  int selectedIndex = 2; // 🔥 favorite aktif

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      final data = await ApiService.getFavorites();

      if (!mounted) return;

      setState(() {
        favorites = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR FAVORITES: $e");

      if (!mounted) return;

      setState(() => isLoading = false);
    }
  }

  /// 🔥 REMOVE FAVORITE REALTIME
  Future<void> removeFavoriteRealtime(int novelId) async {
    try {
      await ApiService.removeFavorite(novelId);

      if (!mounted) return;

      setState(() {
        favorites.removeWhere((n) => n.id == novelId);
      });
    } catch (e) {
      print("ERROR REMOVE FAVORITE: $e");
    }
  }

  /// 🔥 FIX IMAGE
  String getImageUrl(String cover) {
    if (cover.isEmpty) return "";

    if (cover.startsWith('http')) {
      return cover;
    }

    return "http://10.0.2.2:8000/storage/$cover";
  }

  // ================= GRID =================
  Widget buildGridFavoriteNovels() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favorites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.60,
      ),
      itemBuilder: (context, index) {
        final novel = favorites[index];
        final imageUrl = getImageUrl(novel.cover);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailNovelPage(novel: novel),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                /// 🔥 IMAGE
                Positioned.fill(
                  child: imageUrl.isEmpty
                      ? Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                ),

                /// 🔥 GRADIENT
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                ),

                /// 🔥 TITLE
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 6,
                  child: Text(
                    novel.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                /// 🔥 BUTTON UNFAVORITE (REALTIME)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => removeFavoriteRealtime(novel.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= NAV ITEM =================
Widget _navItem({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
  bool isActive = false,
}) {
  return StatefulBuilder(
    builder: (context, setLocalState) {
      bool isHover = false;

      return MouseRegion(
        onEnter: (_) => setLocalState(() => isHover = true),
        onExit: (_) => setLocalState(() => isHover = false),

        child: GestureDetector(
          onTap: onTap,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: (isHover || isActive)
                  ? Colors.white
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              size: 26,
              color: (isHover || isActive)
                  ? color
                  : Colors.black54,
            ),
          ),
        ),
      );
    },
  );
}

  // ================= NAVBAR =================
Widget buildBottomNav() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xffF4E8C1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        /// HOME
        _navItem(
          icon: Icons.home,
          color: Colors.green,
          isActive: false,
          onTap: () => Navigator.pop(context),
        ),

        const SizedBox(width: 16),

        /// BOOKMARK
_navItem(
  icon: Icons.bookmark,
  color: Colors.amber,
  isActive: false,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookmarkPage(),
      ),
    );
  },
),

        const SizedBox(width: 16),

        /// FAVORITE (ACTIVE PAGE)
        _navItem(
          icon: Icons.favorite,
          color: Colors.red,
          isActive: true, // 🔥 cuma ini yang aktif
          onTap: () {},
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),

            const Text(
              "Your Favorites",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : favorites.isEmpty
                      ? const Center(child: Text("No favorites yet"))
                      : SingleChildScrollView(
                          child: buildGridFavoriteNovels(),
                        ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: buildBottomNav(),
    );
  }
}