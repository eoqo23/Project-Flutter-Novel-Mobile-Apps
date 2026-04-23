import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../services/api_services.dart';

class EditChapterPage extends StatefulWidget {
  final Novel novel;

  const EditChapterPage({super.key, required this.novel});

  @override
  State<EditChapterPage> createState() => _EditChapterPageState();
}

class _EditChapterPageState extends State<EditChapterPage> {
  List<Chapter> chapters = [];
  bool isLoading = true;
  String token = "";

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? "";
    fetchChapters();
  }

  Future<void> fetchChapters() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getChapterWithToken(widget.novel.id, token);
      setState(() {
        chapters = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load chapters: $e")),
      );
    }
  }

  // ================= CREATE =================
  void showAddChapterDialog() {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final numberController = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Create Chapter",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= NUMBER =================
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Chapter Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ================= TITLE =================
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ================= CONTENT =================
              TextField(
                controller: contentController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: "Content",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await ApiService.createChapter(
                        widget.novel.id,
                        titleController.text,
                        contentController.text,
                        int.parse(numberController.text),
                        token,
                      );

                      Navigator.pop(context);
                      fetchChapters();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Chapter created successfully"),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Create failed: $e")),
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

  // ================= UPDATE =================
 void showEditDialog(Chapter chapter) {
  final titleController = TextEditingController(text: chapter.title);
  final contentController = TextEditingController(text: chapter.content);
  final numberController =
      TextEditingController(text: chapter.number.toString());

  showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Edit Chapter",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= NUMBER =================
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Chapter Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ================= TITLE =================
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ================= CONTENT =================
              TextField(
                controller: contentController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: "Content",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await ApiService.updateChapter(
                        chapter.id,
                        titleController.text,
                        contentController.text,
                        int.parse(numberController.text),
                        token,
                        widget.novel.id,
                      );

                      Navigator.pop(context);
                      fetchChapters();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Chapter updated successfully"),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Update failed: $e")),
                      );
                    }
                  },
                  child: const Text("Update"),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

  // ================= DELETE =================
  void deleteChapter(int id) async {
    try {
      await ApiService.deleteChapterWithToken(id, token);
      fetchChapters();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chapter deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  // ================= UI CARD =================
  Widget buildChapterItem(Chapter chapter) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Ch ${chapter.number} - ${chapter.title}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => showEditDialog(chapter),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => deleteChapter(chapter.id),
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
      appBar: AppBar(
        title: Text(widget.novel.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddChapterDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: chapters.map(buildChapterItem).toList(),
            ),
    );
  }
}