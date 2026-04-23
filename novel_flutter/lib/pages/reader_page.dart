import 'dart:async';
import 'package:flutter/material.dart';
import 'package:novel_flutter/pages/bookmark_page.dart';
import '../models/novel.dart';
import '../services/api_services.dart';
import '../models/user.dart';
import 'login_page.dart';
import 'detail_novel_page.dart';
import 'favorite_page.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {

  List<Novel> novels = [];
  bool isLoading = true;

  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  final PageController pageController = PageController(viewportFraction: 0.9);

  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchNovels();

    timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (pageController.hasClients && novels.isNotEmpty) {
        int nextPage = pageController.page!.round() + 1;

        if (nextPage >= novels.length) {
          nextPage = 0;
        }

        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void fetchNovels([String query = ""]) async {

    setState(() => isLoading = true);

    try {
      final data = await ApiService.getNovels(search: query);

      setState(() {
        novels = data;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error load data: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    fetchNovels(searchQuery);
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          const Text(
            "Reader",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          ElevatedButton(
            onPressed: logout,
            child: const Text("Logout"),
          )

        ],
      ),
    );
  }

  Widget buildSpotlight() {

    return SizedBox(
      height: 340,

      child: PageView.builder(
        controller: pageController,
        itemCount: novels.length >= 5 ? 5 : novels.length,

        itemBuilder: (context, index) {

          final novel = novels[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),

            child: GestureDetector(
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailNovelPage(novel: novel),
                  ),
                );

              },

              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),

                child: Stack(
                  children: [

                    Positioned.fill(
                      child: Image.network(
                        novel.cover,
                        fit: BoxFit.cover,
                      ),
                    ),

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

                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,

                      child: Text(
                        novel.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildGridNovels() {

    return GridView.builder(

      padding: const EdgeInsets.symmetric(horizontal: 16),

      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemCount: novels.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(

        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.60,

      ),

      itemBuilder: (context, index) {

        final novel = novels[index];

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

                Positioned.fill(
                  child: Image.network(
                    novel.cover,
                    fit: BoxFit.cover,
                  ),
                ),

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
    shadows: [
      Shadow(
        blurRadius: 6,
        color: Colors.black,
        offset: Offset(0, 2),
      )
    ],
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

        /// HOME (ACTIVE)
        _navItem(
          icon: Icons.home,
          color: Colors.black, // 🔥 hitam
          isActive: true, // 🔥 aktif
          onTap: () {},
        ),

        const SizedBox(width: 16),

        /// BOOKMARK
        _navItem(
          icon: Icons.bookmark,
          color: Colors.amber,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookmarkPage()),
            );
          },
        ),

        const SizedBox(width: 16),

        /// FAVORITE
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

  @override
Widget build(BuildContext context) {
  return Scaffold(
    // 🔥 FIX 1: jangan transparent (ini bikin UI beda & glitch feel)
    backgroundColor: Colors.transparent,

    body: Column(
      children: [

        // ================= TOP BAR =================
        buildTopBar(),

        // ================= SEARCH =================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,

            decoration: InputDecoration(
              hintText: "Search novels...",
              filled: true,
              fillColor: Colors.white, // 🔥 FIX biar sama Home feel

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),

              suffixIcon: const Icon(Icons.search),
            ),
          ),
        ),

        // ================= CONTENT =================
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())

              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Newest",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black, // 🔥 FIX biar konsisten
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      buildSpotlight(),

                      const SizedBox(height: 20),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Our Novels",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      buildGridNovels(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ],
    ),

    bottomNavigationBar: buildBottomNav(),
  );
}
}