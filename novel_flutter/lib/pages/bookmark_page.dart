import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../pages/read_page_novel.dart';
import 'favorite_page.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List bookmarks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookmarks();
  }

  Future<void> fetchBookmarks() async {
    try {
      final data = await ApiService.getBookmarks();

      if (!mounted) return;

      setState(() {
        bookmarks = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> removeBookmark(int chapterId) async {
    try {
      await ApiService.removeBookmark(chapterId);

      setState(() {
        bookmarks.removeWhere((b) => b['chapter_id'] == chapterId);
      });
    } catch (e) {}
  }

  String getImageUrl(String cover) {
    if (cover.isEmpty) return "";
    if (cover.startsWith('http')) return cover;
    return "http://10.0.2.2:8000/storage/$cover";
  }

  // ================= ITEM =================
  Widget buildBookmarkItem(Map data) {
    final imageUrl = getImageUrl(data['cover'] ?? "");
    final chapterNumber = (data['chapter_number'] ?? 0).toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isEmpty
                ? Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  )
                : Image.network(
                    imageUrl,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  data['novel_title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                Text(
                  "Chapter Number : ($chapterNumber)",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  data['chapter_title'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.amber),
            onPressed: () => removeBookmark(data['chapter_id']),
          ),
        ],
      ),
    );
  }

  // ================= NAVBAR (SAMA KAYAK HOME) =================
  Widget _navItem({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 26,
          color: isActive ? color : Colors.black54,
        ),
      ),
    );
  }

  Widget buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
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

          _navItem(
            icon: Icons.home,
            color: Colors.black,
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(width: 16),

          _navItem(
            icon: Icons.bookmark,
            color: Colors.amber,
            isActive: true,
            onTap: () {},
          ),

          const SizedBox(width: 16),

          _navItem(
            icon: Icons.favorite,
            color: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Column(
        children: [

          const SizedBox(height: 10),

          const Text(
            "Bookmarks",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookmarks.isEmpty
                    ? const Center(
                        child: Text(
                          "No bookmarks yet",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchBookmarks,
                        child: ListView.builder(
                          itemCount: bookmarks.length,
                          itemBuilder: (context, index) {
                            return buildBookmarkItem(bookmarks[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),

      bottomNavigationBar: buildBottomNav(),
    );
  }
}