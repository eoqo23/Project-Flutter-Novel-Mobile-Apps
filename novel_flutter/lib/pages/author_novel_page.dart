  import 'package:flutter/material.dart';
  import '../models/novel.dart';
  import '../services/api_services.dart';
  import 'create_novel_page.dart';
  import 'edit_novel_page.dart';
  import 'edit_chapter_page.dart';

  class AuthorNovelPage extends StatefulWidget {
  const AuthorNovelPage({super.key});

  @override
  State<AuthorNovelPage> createState() => _AuthorNovelPageState();
  }

  class _AuthorNovelPageState extends State<AuthorNovelPage> {
  List<Novel> novels = [];
  bool isLoading = true;

  @override
  void initState() {
  super.initState();
  fetchMyNovels();
  }

  Future<void> fetchMyNovels() async {
  setState(() => isLoading = true);
  try {
  final data = await ApiService.getMyNovels();
  setState(() {
  novels = data;
  });
  } catch (e) {
  if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Error: $e")),
  );
  }
  } finally {
  if (mounted) {
  setState(() => isLoading = false);
  }
  }
  }

  Future<void> deleteNovel(int id) async {
  try {
  await ApiService.deleteNovel(id);
  fetchMyNovels();
  } catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Delete failed: $e")),
  );
  }
  }

 // ================= ITEM CARD =================
Widget buildNovelItem(Novel novel) {

  // ================= COVER FIX =================
  String coverUrl = "";

  if (novel.cover != null && novel.cover.toString().isNotEmpty) {

    // kalau sudah URL full (http/https)
    if (novel.cover.startsWith("http")) {
      coverUrl = novel.cover;

    } else {
      // kalau cuma path dari storage Laravel
      coverUrl = "${ApiService.baseUrl}/storage/${novel.cover.replaceAll(RegExp(r'^/'), '')}";
    }
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [

        // ================= COVER =================
        Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[300],
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.network(
            coverUrl.isNotEmpty ? coverUrl : "",
            fit: BoxFit.cover,

            // 🔥 kalau gagal load image
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              );
            },

            // 🔥 kalau kosong
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        // ================= INFO =================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                novel.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 6),

              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditChapterPage(novel: novel),
                    ),
                  );
                  fetchMyNovels();
                },
                child: const Text("Edit Chapter"),
              ),

              const SizedBox(height: 4),

              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditNovelPage(novel: novel),
                    ),
                  );
                  fetchMyNovels();
                },
                child: const Text("Edit Novel"),
              ),

              const SizedBox(height: 4),

              GestureDetector(
                onTap: () => deleteNovel(novel.id),
                child: const Text(
                  "Delete Novel",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  // ================= MAIN =================
  @override
  Widget build(BuildContext context) {
  return Scaffold(
  backgroundColor: Colors.transparent,
  body: SafeArea(
  child: Column(
  children: [

          // HEADER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Back",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const Text(
            "Your Novel",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : novels.isEmpty
                    ? const Center(
                        child: Text(
                          "You don't have any novels yet.",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        itemCount: novels.length,
                        itemBuilder: (context, index) {
                          return buildNovelItem(novels[index]);
                        },
                      ),
          ),

          // CREATE BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateNovelPage(),
                  ),
                );
                fetchMyNovels();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline, size: 30),
                  SizedBox(width: 10),
                  Text(
                    "Create New Novel",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );


  }
  }
