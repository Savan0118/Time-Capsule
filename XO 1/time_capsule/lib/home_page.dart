// This is home_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date
import 'search_page.dart';
import 'settings_page.dart';
import 'mood_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, String>> memories = const [
    // You can add memory items here
  ];

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFD2B48C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.hourglass_bottom, size: 36, color: Colors.black87),
                  SizedBox(width: 10),
                  Text(
                    "Time Capsule",
                    style: TextStyle(
                      fontSize: 34,
                      fontFamily: "DancingScript", // Fancy Script font
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Your mood capsules await!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Fancy Script", // Fancy Script font
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Date: $todayDate",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Arial",
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: memories.length,
                  itemBuilder: (context, index) {
                    final memory = memories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Color(int.parse(memory["color"]!)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        title: Text(
                          memory["title"]!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          memory["date"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black87),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black87),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFB98C65),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              _smoothRoute(const SearchPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              _smoothRoute(const MoodPage()), // Navigate to MoodPage
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              _smoothRoute(const SettingsPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28, color: Colors.black),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box, size: 28, color: Colors.black),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 28, color: Colors.black),
            label: "Settings",
          ),
        ],
      ),
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
}
