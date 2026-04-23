  import 'package:flutter/material.dart';
  import '../models/novel.dart';
  import '../models/chapter.dart';
  import '../services/api_services.dart';
  import 'read_page_novel.dart';

  class DetailNovelPage extends StatefulWidget {
    final Novel novel;

    const DetailNovelPage({super.key, required this.novel});

    @override
    State<DetailNovelPage> createState() => _DetailNovelPageState();
  }

  class _DetailNovelPageState extends State<DetailNovelPage> {
    List<Chapter> chapters = [];
    bool isLoading = true;

    // 🔥 STATE FAVORIT
    bool isFavorited = false;
    bool isProcessing = false; // 🔥 untuk mencegah spam

    @override
    void initState() {
      super.initState();

      // 🔥 ambil dari API
      isFavorited = widget.novel.isFavorited;
      
      fetchChapters();
      Future.microtask(() => refreshFavoriteStatus());
    }

    // ================= FETCH CHAPTER =================
  void fetchChapters() async {
    try {
      final data = await ApiService.getChapters(widget.novel.id);

      if (!mounted) return; // 🔥 WAJIB

      setState(() {
        chapters = data;
        isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error load chapter: $e")),
      );
    }
  }

  Future<void> refreshFavoriteStatus() async {
    try {
      final favorites = await ApiService.getFavorites();

      final isFav = favorites.any((n) => n.id == widget.novel.id);

      if (!mounted) return;

      setState(() {
        isFavorited = isFav;
      });

    } catch (e) {
      print("ERROR REFRESH FAVORITE: $e");
    }
  }

    // ================= TOGGLE FAVORITE =================
  Future<void> toggleFavorite() async {
    if (isProcessing) return; // 🔥 cegah spam

    setState(() {
      isProcessing = true;
      isFavorited = !isFavorited;
    });

    try {
      if (isFavorited) {
        await ApiService.addFavorite(widget.novel.id);
      } else {
        await ApiService.removeFavorite(widget.novel.id);
      }
    } catch (e) {
      // rollback kalau gagal
      if (!mounted) return;

      setState(() {
        isFavorited = !isFavorited;
      });
    }

    if (!mounted) return;

    setState(() {
      isProcessing = false;
    });
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("Detail Novel"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox(height: 20),

              /// COVER
              Container(
                height: 160,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black26,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.novel.cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// TITLE
              Text(
                widget.novel.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                widget.novel.author,
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              /// SINOPSIS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Sinopsis",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 5),

                    Text(widget.novel.description),

                    const SizedBox(height: 10),

                    Text(
                      "Genre : ${widget.novel.genres}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 15),

                    /// 🔥 FAVORITE + VIEW
                    Row(
                      children: [

                        /// ❤️ FAVORITE BUTTON
  IconButton(
    icon: Icon(
      isFavorited ? Icons.favorite : Icons.favorite_border,
      color: Colors.red,
    ),
    onPressed: isProcessing ? null : toggleFavorite,
  ),

                        Text("${widget.novel.likesCount}"),

                        const SizedBox(width: 20),

                        /// 👁 VIEW
                        const Icon(Icons.remove_red_eye,
                            color: Colors.blue, size: 16),
                        const SizedBox(width: 5),
                        Text("${widget.novel.viewCount}"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ================= CHAPTER LIST =================
              isLoading
                  ? const CircularProgressIndicator()
                  : chapters.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "Belum ada chapter",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chapters.length,
                          itemBuilder: (context, index) {
                            final chapter = chapters[index];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReadNovelPage(
                                      chapterId: chapter.id,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                decoration: BoxDecoration(
                                  color: index % 2 == 0
                                      ? Colors.grey[300]
                                      : Colors.grey[200],
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Chapter ${chapter.number}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Text(chapter.title),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        )
            ],
          ),
        ),
      );
    }
  }