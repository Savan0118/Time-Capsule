// This is help_support_page.dart

import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2B48C),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Help & Support",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            children: [
              _buildSection(
                title: "Getting Started",
                content:
                    "Welcome to Capsule Memories! To get started, create an account using your email. "
                    "Once registered, you can start adding, categorizing, and personalizing your memories. "
                    "Explore the features and settings to adjust notifications, themes, and privacy preferences to your liking.",
              ),
              _buildSection(
                title: "Managing Memories",
                content:
                    "You can add new memories by tapping the '+' icon in the main screen. "
                    "Each memory can have a title, description, date, optional colors, and tags for easy organization. "
                    "Editing and deleting memories is simple: just select the memory and choose the corresponding option. "
                    "Remember, all your memories are securely stored and encrypted for privacy.",
              ),
              _buildSection(
                title: "Account Settings",
                content:
                    "Access your profile to update personal information, change passwords, or manage your notification preferences. "
                    "Ensure your email is always up-to-date to receive important updates or account recovery instructions. "
                    "If you encounter any login issues, use the 'Forgot Password' option to reset your credentials securely.",
              ),
              _buildSection(
                title: "Troubleshooting",
                content:
                    "If you experience technical issues such as app crashes, loading errors, or memory sync problems, try the following steps:\n\n"
                    "• Restart the app and check your internet connection.\n"
                    "• Clear the app cache from your device settings.\n"
                    "• Ensure the app is updated to the latest version.\n"
                    "• If problems persist, contact our support team with details of the issue.",
              ),
              _buildSection(
                title: "Contacting Support",
                content:
                    "For any questions, feedback, or technical issues, reach out to our support team:\n\n"
                    "• Email: timecapsule@app.com\n"
                    "• Response Time: Typically within 24-48 hours\n"
                    "• Support Scope: Account assistance, troubleshooting, privacy concerns, and feature guidance.\n\n"
                    "We strive to provide prompt and professional assistance to ensure a smooth and enjoyable experience for all users.",
              ),
              _buildSection(
                title: "FAQs",
                content:
                    "1. Can I recover deleted memories?\n"
                    "   - Deleted memories are permanently removed and cannot be restored.\n\n"
                    "2. How is my data secured?\n"
                    "   - All data is encrypted in transit and at rest using industry-standard security measures.\n\n"
                    "3. Can I share memories with others?\n"
                    "   - Currently, sharing is limited to in-app features, ensuring privacy and security.\n\n"
                    "4. What devices are supported?\n"
                    "   - Capsule Memories works on Android and iOS devices with the latest app version installed.",
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "We are committed to providing the best support experience. "
                  "If you have any questions not covered here, please contact our team anytime.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
