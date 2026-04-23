import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../models/chapter.dart';

class ReadNovelPage extends StatefulWidget {
  final int chapterId;

  const ReadNovelPage({super.key, required this.chapterId});

  @override
  State<ReadNovelPage> createState() => _ReadNovelPageState();
}

class _ReadNovelPageState extends State<ReadNovelPage> {
  late Future<Chapter> chapter;

  int likeCount = 0;
  int commentCount = 0;

  bool isBookmarked = false;
  bool isBookmarkLoaded = false; // 🔥 FIX FLICKER
  bool isInitialized = false;

  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadChapter();
  }

  void loadChapter() {
    chapter = ApiService.getChapter(widget.chapterId);
    isInitialized = false;
    isBookmarkLoaded = false; // 🔥 reset tiap pindah chapter
  }

  // ================= BOOKMARK =================

  Future<void> checkBookmark() async {
    try {
      final bookmarks = await ApiService.getBookmarks();

      if (!mounted) return;

      setState(() {
        isBookmarked = bookmarks.any(
          (b) => b['chapter_id'] == widget.chapterId,
        );
        isBookmarkLoaded = true; // 🔥 selesai load
      });
    } catch (e) {
      print("Bookmark check error: $e");

      if (!mounted) return;
      setState(() => isBookmarkLoaded = true);
    }
  }

  Future<void> toggleBookmark(int novelId) async {
    final previousState = isBookmarked;

    // 🔥 langsung update UI (instant)
    setState(() {
      isBookmarked = !isBookmarked;
    });

    try {
      if (!previousState) {
        await ApiService.addBookmark(novelId, widget.chapterId);
      } else {
        await ApiService.removeBookmark(widget.chapterId);
      }
    } catch (e) {
      // 🔥 rollback kalau gagal
      setState(() {
        isBookmarked = previousState;
      });

      print("Bookmark error: $e");
    }
  }

  // ================= COMMENT =================

  Future<void> loadComments() async {
    try {
      final comments = await ApiService.getComments(widget.chapterId);

      if (!mounted) return;

      setState(() {
        commentCount = comments.length;
      });
    } catch (e) {
      print("Comment error: $e");
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Reading"),
      ),
      body: FutureBuilder<Chapter>(
        future: chapter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;

          // 🔥 INIT SEKALI (ANTI BUG)
          if (!isInitialized) {
            isInitialized = true;

            likeCount = data.likesCount ?? 0;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              checkBookmark(); // 🔥 ambil status bookmark
              loadComments();
            });
          }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "Chapter : ${data.title}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          data.content,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= BOTTOM BAR =================
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffF4E8C1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// 🔥 BOOKMARK FIX (NO FLICKER)
                    isBookmarkLoaded
                        ? IconButton(
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isBookmarked
                                  ? Colors.amber
                                  : Colors.black,
                              size: 28,
                            ),
                            onPressed: () => toggleBookmark(data.novelId),
                          )
                        : const SizedBox(
                            width: 28,
                            height: 28,
                          ),

                    /// 🔥 NAVIGATION
                    Row(
                      children: [

                        /// BACK
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: data.prevId == null
                              ? null
                              : () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReadNovelPage(
                                        chapterId: data.prevId!,
                                      ),
                                    ),
                                  );
                                },
                          child: const Text("Back"),
                        ),

                        const SizedBox(width: 10),

                        /// NEXT
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: data.nextId == null
                              ? null
                              : () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReadNovelPage(
                                        chapterId: data.nextId!,
                                      ),
                                    ),
                                  );
                                },
                          child: const Text("Next"),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}