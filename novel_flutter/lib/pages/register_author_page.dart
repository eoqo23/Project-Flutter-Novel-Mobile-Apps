import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterAuthorPage extends StatefulWidget {
  const RegisterAuthorPage({super.key});

  @override
  State<RegisterAuthorPage> createState() => _RegisterAuthorPageState();
}

class _RegisterAuthorPageState extends State<RegisterAuthorPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController penNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  bool isLoading = false;

  void registerAuthor() async {

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Author registered successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Register Author"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            Text(
              "Become an Author",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: penNameController,
              decoration: InputDecoration(
                labelText: "Pen Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Author Bio",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : registerAuthor,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register Author"),
              ),
            )
          ],
        ),
      ),
    );
  }
}