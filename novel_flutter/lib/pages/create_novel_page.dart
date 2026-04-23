import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_services.dart';
import '../models/genre.dart'; // ✅ TAMBAH INI

class CreateNovelPage extends StatefulWidget {
  const CreateNovelPage({super.key});

  @override
  State<CreateNovelPage> createState() => _CreateNovelPageState();
}

class _CreateNovelPageState extends State<CreateNovelPage> {
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
    fetchGenres(); // 🔥 AMBIL GENRE DARI API
    loadGenres(); // ✅ LOAD GENRE
  }

  // ================= LOAD GENRE =================
void loadGenres() async {
  try {
    final data = await ApiService.getGenres();
    print("GENRES DATA: $data"); // 👈 TAMBAH INI

    setState(() {
      genres = data;
    });
  } catch (e) {
    print("ERROR GENRE: $e");
  }
}

Future<void> fetchGenres() async {
  try {
    final data = await ApiService.getGenres();

    print("GENRES: $data"); // 🔥 DEBUG

    setState(() {
      genres = data;
    });
  } catch (e) {
    print("ERROR GENRE: $e");
  }
}

  // ================= PICK IMAGE =================
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        pickedImage = picked;
      });
    }
  }

  // ================= CREATE =================
  void createNovel() async {
    setState(() => isLoading = true);

    try {
      await ApiService.createNovel(
        title: titleController.text,
        description: descController.text,
        genres: selectedGenres,
        image: pickedImage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Novel berhasil dibuat")),
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

              /// BACK
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "Back",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              /// ================= COVER =================
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
        child: FutureBuilder(
          future: pickedImage!.readAsBytes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          },
        ),
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

              /// GENRE
              const Text("Genre"),
              const SizedBox(height: 5),

              genres.isEmpty
    ? const Center(child: CircularProgressIndicator()) // loading
    : Wrap(
        spacing: 8,
        children: genres.map((genre) {
          final id = int.parse(genre['id'].toString()); // pastikan id adalah int
          final name = genre['name'];
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
                  onPressed: isLoading ? null : createNovel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Create"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}