// This is settings_page.dart

import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'forgot_password_page.dart';
import 'about_us_page.dart';
import 'privacy_policy_page.dart';
import 'help_support_page.dart';
import 'signin_page.dart'; // ⬅️ Import SignInPage

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7B899), // common background
      appBar: AppBar(
        backgroundColor: const Color(0xFFD7B899),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSettingsButton("Profile", Icons.person, () {
              Navigator.push(
                context,
                _createSmoothRoute(const ProfilePage()),
              );
            }),
            const SizedBox(height: 15),
            _buildSettingsButton("Update Password", Icons.lock, () {
              Navigator.push(
                context,
                _createSmoothRoute(const ForgotPasswordPage()),
              );
            }),
            const SizedBox(height: 15),
            _buildSettingsButton("About Us", Icons.info, () {
              Navigator.push(
                context,
                _createSmoothRoute(const AboutUsPage()),
              );
            }),
            const SizedBox(height: 15),
            _buildSettingsButton("Privacy Policy", Icons.privacy_tip, () {
              Navigator.push(
                context,
                _createSmoothRoute(const PrivacyPolicyPage()),
              );
            }),
            const SizedBox(height: 15),
            _buildSettingsButton("Help & Support", Icons.help, () {
              Navigator.push(
                context,
                _createSmoothRoute(const HelpSupportPage()),
              );
            }),
            const SizedBox(height: 15),
            _buildSettingsButton("Logout", Icons.logout, () {
              Navigator.pushAndRemoveUntil(
                context,
                _createSmoothRoute(const SignInPage()),
                (route) => false, // removes all previous routes
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(String text, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5D4037), // dark brown
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }

  // Smooth fade transition for navigation
  Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
