import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';
import 'home_page.dart';
import 'author_page.dart';
import 'admin_page.dart';
import 'reader_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void login() async {
    setState(() => isLoading = true);

    try {
      final user = await ApiService.login(
        emailController.text,
        passwordController.text,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token);
      await prefs.setString('role', user.role);

      if (!mounted) return;

      if (user.role == 'reader') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ReaderPage()));
      } else if (user.role == 'author') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AuthorPage()));
      } else if (user.role == 'admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminNovelPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [

            /// BACK BUTTON
           /// BACK BUTTON
Positioned(
  top: 10,
  left: 20,
  child: GestureDetector(
    onTap: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    },
    child: Text(
      "Back",
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black.withOpacity(0.8),
      ),
    ),
  ),
),

            /// LOGIN CONTENT
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// APP TITLE
                      Text(
                        "Nauvel",
                        style: GoogleFonts.poppins(
                          fontSize: 45,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withOpacity(0.8),
                          letterSpacing: -1,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Read your favorite stories",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),

                      const SizedBox(height: 60),

                      /// EMAIL
                      _buildTextField(
                        controller: emailController,
                        label: "Email Address",
                        icon: Icons.email_outlined,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 20),

                      /// PASSWORD
                      _buildTextField(
                        controller: passwordController,
                        label: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 40),

                      /// LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[600],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  "Log In",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.amber[700], size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}