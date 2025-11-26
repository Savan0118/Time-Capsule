// This is privacy_policy_page.dart

import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          "Privacy Policy",
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
                title: "Introduction",
                content:
                    "Capsule Memories respects your privacy and is committed to protecting your personal information. "
                    "This Privacy Policy describes how we collect, use, and safeguard your data when using the application. "
                    "Your continued use constitutes consent to our practices and policies outlined below. "
                    "We are dedicated to transparency and accountability in all data handling procedures.",
              ),
              _buildSection(
                title: "Information We Collect",
                content:
                    "• Personal Information: Name, email, and account credentials provided during registration.\n"
                    "• Memory Data: Photos, notes, and other content stored in your account.\n"
                    "• Usage Data: App interaction data, feature usage, and access times.\n"
                    "• Cookies & Analytics: Data used for enhancing user experience, performance monitoring, and analytics.\n"
                    "We only collect data necessary to improve functionality, provide support, and personalize the app experience.",
              ),
              _buildSection(
                title: "How We Use Your Information",
                content:
                    "• To securely store and manage your memories.\n"
                    "• To authenticate your account and maintain security.\n"
                    "• To personalize features, recommendations, and settings.\n"
                    "• To communicate important updates or policy changes.\n"
                    "• To analyze usage patterns for app improvement.\n"
                    "• To comply with legal requirements when necessary.",
              ),
              _buildSection(
                title: "Data Security",
                content:
                    "We implement industry-standard security measures including encryption for data at rest and in transit. "
                    "Regular monitoring and security updates ensure that your data remains protected. "
                    "While we strive for maximum security, no system is completely immune to breaches. "
                    "Users are encouraged to use strong passwords and keep account information confidential.",
              ),
              _buildSection(
                title: "Sharing and Disclosure",
                content:
                    "Capsule Memories does not sell, rent, or trade personal data to third parties. "
                    "Information may only be shared with consent, legal obligation, or with trusted service providers who operate under strict confidentiality agreements. "
                    "We prioritize user privacy in all situations and limit data access strictly to operational needs.",
              ),
              _buildSection(
                title: "Your Rights",
                content:
                    "• Access personal data stored in the app.\n"
                    "• Update or correct your information.\n"
                    "• Request deletion of your account and stored memories.\n"
                    "• Contact support at support@capsulememories.com for privacy inquiries.\n"
                    "All requests are handled promptly and transparently.",
              ),
              _buildSection(
                title: "Policy Updates",
                content:
                    "This Privacy Policy may be updated periodically. "
                    "Major changes will be communicated via app updates or notifications. "
                    "We encourage users to review this page regularly to stay informed about how we protect your data and respect your privacy.",
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Thank you for trusting Capsule Memories. Your privacy is our priority, and we are committed to safeguarding your data.",
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
