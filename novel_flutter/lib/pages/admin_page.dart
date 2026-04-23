import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/novel.dart';
import '../services/api_services.dart';
import 'login_page.dart';

class AdminNovelPage extends StatefulWidget {
  const AdminNovelPage({super.key});

  @override
  State<AdminNovelPage> createState() => _AdminNovelPageState();
}

class _AdminNovelPageState extends State<AdminNovelPage> {
  List<Novel> novels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNovels();
  }

  Future<void> fetchNovels() async {
    setState(() => isLoading = true);

    try {
      final data = await ApiService.getAllNovelsAdmin();
      setState(() => novels = data);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$e")));
    }

    setState(() => isLoading = false);
  }

Future<void> updateStatus(Novel novel) async {
  final newStatus =
      novel.status == "published" ? "draft" : "published";

  try {
    await ApiService.updateNovelStatus(novel.id, newStatus);

    setState(() {
      final index = novels.indexWhere((n) => n.id == novel.id);
      if (index != -1) {
        novels[index] = Novel(
          id: novel.id,
          title: novel.title,
          author: novel.author,
          cover: novel.cover,
          description: novel.description,
          genres: novel.genres,
          likesCount: novel.likesCount,
          viewCount: novel.viewCount,
          status: newStatus, // 🔥 ubah di sini
          isFavorited: novel.isFavorited,
        );
      }
    });
  } catch (e) {
    print(e);
  }
}

  Future<void> deleteNovel(int id) async {
    await ApiService.deleteNovelAdmin(id);
    await fetchNovels();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Widget statusBadge(String status) {
    Color color = status == "published"
        ? Colors.green
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildItem(Novel novel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [

              /// TITLE + STATUS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      novel.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 6),

                    statusBadge(novel.status),
                  ],
                ),
              ),

              /// ACTIONS
              Row(
                children: [

                  /// CHANGE STATUS
                  IconButton(
                    tooltip: "Toggle Status",
                    icon: const Icon(Icons.sync),
                    onPressed: () => updateStatus(novel),
                  ),

                  /// DELETE
                  IconButton(
                    tooltip: "Delete Novel",
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Novel"),
                          content: const Text(
                              "Are you sure you want to delete this novel?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                deleteNovel(novel.id);
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text("Admin Panel"),
        actions: [

          /// LOGOUT BUTTON
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : novels.isEmpty
              ? const Center(
                  child: Text("No novels found"),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  itemCount: novels.length,
                  itemBuilder: (context, index) {
                    return buildItem(novels[index]);
                  },
                ),
    );
  }
}