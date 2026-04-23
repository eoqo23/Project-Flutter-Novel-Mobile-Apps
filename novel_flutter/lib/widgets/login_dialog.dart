import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../models/user.dart';

class LoginDialog extends StatefulWidget {
  final Function(User) onLoginSuccess;

  const LoginDialog({super.key, required this.onLoginSuccess});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  void login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      User user = await ApiService.login(
        emailController.text,
        passwordController.text,
      );

      widget.onLoginSuccess(user);
      Navigator.pop(context); // tutup dialog
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xffE8D9B5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Password"),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : login,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text("Login"),
        ),
      ],
    );
  }
}