// lib/signin_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'forgot_password_page.dart';
import 'user_db.dart';
import 'user_model.dart';
import 'session_manager.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _authenticating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2B48C),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Sign in Now",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Georgia",
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildTextField("Email", false, _emailController, (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  }),
                  const SizedBox(height: 20),

                  _buildTextField("Password", true, _passwordController, (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password cannot be empty';
                    }
                    return null;
                  }),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, _smoothRoute(const ForgotPasswordPage()));
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(0xFF6B3E26),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  _authenticating
                      ? const CircularProgressIndicator()
                      : _buildButton("Sign In", _handleSignIn),

                  const SizedBox(height: 40),

                  const Text(
                    "If you don’t have an account",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildButton("Register", () {
                    Navigator.push(context, _smoothRoute(const RegisterPage()));
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, bool isPassword, TextEditingController controller,
      String? Function(String?) validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFDCDCDC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      child: Text(text),
    );
  }

  Route _smoothRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _authenticating = true);

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    try {
      final User? user = await UserDB.instance.getUserByEmail(email);

      if (user == null) {
        if (mounted) {
          setState(() => _authenticating = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No account found for this email"), backgroundColor: Colors.red));
        }
        return;
      }

      if (user.password.trim() != password) {
        if (mounted) {
          setState(() => _authenticating = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect password"), backgroundColor: Colors.red));
        }
        return;
      }

      // Save login session with user id to ensure privacy
      if (user.id == null) {
        if (mounted) {
          setState(() => _authenticating = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid user record"), backgroundColor: Colors.red));
        }
        return;
      }

      await SessionManager.saveLogin(email: email, userId: user.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login successful"), backgroundColor: Colors.green));
      }

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      Navigator.pushReplacement(context, _smoothRoute(const HomePage()));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Authentication failed"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _authenticating = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
