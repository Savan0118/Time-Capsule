// This is about_us_page.dart

import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
          "About Us",
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
                title: "About Capsule Memories",
                content:
                    "Capsule Memories is designed to help you capture, organize, and relive your most cherished moments. "
                    "From family celebrations to personal achievements, our platform ensures that every memory is preserved securely. "
                    "Our team is passionate about creating an experience that is both intuitive and visually engaging, so users can easily navigate through their memories and share them with friends and family if they choose to. "
                    "Our commitment to security means all memories are encrypted and private, giving you peace of mind.",
              ),
              _buildSection(
                title: "Our Mission",
                content:
                    "Our mission is to create a safe, user-friendly environment where memories can be preserved and revisited anytime. "
                    "We aim to provide features that allow categorization, tagging, and even visual customization of memories so that every memory feels personal and meaningful. "
                    "By simplifying memory preservation, we empower users to focus on creating moments rather than worrying about losing them.",
              ),
              _buildSection(
                title: "Our Vision",
                content:
                    "We envision a world where memories are never lost, forgotten, or inaccessible. "
                    "Capsule Memories aspires to become the leading platform for memory preservation by continuously innovating and adding features that enhance usability and privacy. "
                    "Our long-term goal is to integrate smart reminders, AI-powered memory organization, and collaborative sharing tools to make memory management effortless and enjoyable.",
              ),
              _buildSection(
                title: "Why Choose Capsule Memories?",
                content:
                    "• Secure Storage: All memories are encrypted and securely stored.\n"
                    "• User-Friendly Interface: Designed for effortless navigation and interaction.\n"
                    "• Personalized Experience: Organize memories with tags, dates, and color-coded highlights.\n"
                    "• Continuous Innovation: Regular updates to improve user experience and introduce new features.\n"
                    "• Privacy First: Your data remains your own and is never shared without consent.\n"
                    "• Accessibility: Access your memories anytime, anywhere, across multiple devices.",
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Thank you for trusting Capsule Memories. We are dedicated to keeping your memories safe, accessible, and beautifully organized.",
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
