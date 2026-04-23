import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_services.dart';
import '../models/novel.dart';

class EditNovelPage extends StatefulWidget {
  final Novel novel;

  const EditNovelPage({super.key, required this.novel});

  @override
  State<EditNovelPage> createState() => _EditNovelPageState();
}

class _EditNovelPageState extends State<EditNovelPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  List<int> selectedGenres = [];
  List<dynamic> genres = []; // 🔥 dari API

  XFile? pickedImage;
  final picker = ImagePicker();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // 🔥 isi data lama
    titleController.text = widget.novel.title;
    descController.text = widget.novel.description;

    fetchGenres();
  }

  Future<void> fetchGenres() async {
    final data = await ApiService.getGenres(); // 🔥 ambil dari API
    setState(() {
      genres = data;
    });
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        pickedImage = picked;
      });
    }
  }

  void updateNovel() async {
    setState(() => isLoading = true);

    try {
      await ApiService.updateNovelFull(
        id: widget.novel.id,
        title: titleController.text,
        description: descController.text,
        genres: selectedGenres,
        image: pickedImage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Novel berhasil diupdate")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget inputBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "Back",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              /// COVER
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 120,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: pickedImage == null
                        ? const Icon(Icons.add, size: 40)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: kIsWeb
                                ? Image.network(pickedImage!.path, fit: BoxFit.cover)
                                : Image.file(File(pickedImage!.path), fit: BoxFit.cover),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text("Detail", style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              /// TITLE
              const Text("Title"),
              const SizedBox(height: 5),
              inputBox(
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),

              const SizedBox(height: 15),

              /// SINOPSIS
              const Text("Sinopsis"),
              const SizedBox(height: 5),
              inputBox(
                child: TextField(
                  controller: descController,
                  maxLines: 5,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),

              const SizedBox(height: 15),

              /// GENRE (🔥 DINAMIS)
              const Text("Genre"),
              const SizedBox(height: 5),

              Wrap(
                spacing: 8,
                children: genres.map((g) {
                  final id = g['id'];
                  final name = g['name'];
                  final isSelected = selectedGenres.contains(id);

                  return ChoiceChip(
                    label: Text(name),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        isSelected
                            ? selectedGenres.remove(id)
                            : selectedGenres.add(id);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateNovel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Update"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}