import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novel_flutter/pages/bookmark_page.dart';
import '../models/novel.dart';
import '../services/api_services.dart';
import '../models/user.dart';
import 'login_page.dart';
import 'detail_novel_page.dart';
import 'author_novel_page.dart';
import 'favorite_page.dart';

class AuthorPage extends StatefulWidget {
  const AuthorPage({super.key});

  @override
  State<AuthorPage> createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {

  List<Novel> novels = [];
  bool isLoading = true;
  User? currentUser;

  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  final PageController pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    fetchNovels();
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

  // ================= HEADER =================

  Widget buildTopBar() {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),

      child: Row(
        children: [

          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              currentUser?.name ?? "Author",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Wrap(
            spacing: 6,
            children: [

              ElevatedButton(
                onPressed: () async {

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthorNovelPage(),
                    ),
                  );

                  fetchNovels();
                },

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),

                child: const Text(
                  "Create Novel",
                  style: TextStyle(fontSize: 12),
                ),
              ),

              ElevatedButton(
                onPressed: logout,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),

                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 12),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  // ================= SPOTLIGHT =================

  Widget buildSpotlight() {

    return SizedBox(
      height: 340,

      child: PageView.builder(
        controller: pageController,
        itemCount: novels.length >= 5 ? 5 : novels.length,

        itemBuilder: (context, index) {

          final novel = novels[index];

          return AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {

              double value = 1;

              if (pageController.position.haveDimensions) {
                value = pageController.page! - index;
                value = (1 - (value.abs() * 0.15)).clamp(0.9, 1);
              }

              return Center(
                child: Transform.scale(
                  scale: value,
                  child: child,
                ),
              );
            },

            child: Padding(
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
            ),
          );
        },
      ),
    );
  }

  // ================= GRID =================

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
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  // ================= NAVBAR =================
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

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.transparent,

      body: Column(
        children: [

          buildTopBar(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,

              decoration: InputDecoration(
                hintText: "Search novels...",
                filled: true,
                fillColor: Colors.grey[200],

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),

                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),

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