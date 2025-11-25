// This is mood_themes.dart

import 'package:flutter/material.dart';

class MoodTheme {
  final Color mainColor;
  final Color bottomNavColor;

  MoodTheme({required this.mainColor, required this.bottomNavColor});
}

class MoodThemes {
  static final Map<String, MoodTheme> moods = {
    // Positive
    "Happy": MoodTheme(mainColor: const Color(0xFFFFC300), bottomNavColor: const Color(0xFFFFB74D)),
    "Loving": MoodTheme(mainColor: const Color(0xFFFF6B9D), bottomNavColor: const Color(0xFFAD1457)),
    "Excited": MoodTheme(mainColor: const Color(0xFFFF5400), bottomNavColor: const Color(0xFFD32F2F)),
    "Relaxed": MoodTheme(mainColor: const Color(0xFF90E0EF), bottomNavColor: const Color(0xFF00796B)),

    // Negative
    "Sad": MoodTheme(mainColor: const Color(0xFF48CAE4), bottomNavColor: const Color(0xFF1565C0)),
    "Angry": MoodTheme(mainColor: const Color(0xFFE63946), bottomNavColor: const Color(0xFFB71C1C)),
    "Lonely": MoodTheme(mainColor: const Color(0xFF6D6875), bottomNavColor: const Color(0xFF4527A0)),
    "Bored": MoodTheme(mainColor: const Color(0xFF8A8A8A), bottomNavColor: const Color(0xFF5D4037)),

    // Neutral
    "Serious": MoodTheme(mainColor: const Color(0xFF5E5E5E), bottomNavColor: const Color(0xFF37474F)),
    "Calm": MoodTheme(mainColor: const Color(0xFF81C784), bottomNavColor: const Color(0xFF2E7D32)),    
    "Tired": MoodTheme(mainColor: const Color(0xFFC5C5C5), bottomNavColor: const Color(0xFF6A1B9A)),
    "Nostalgic": MoodTheme(mainColor: const Color(0xFFCFBAF0), bottomNavColor: const Color(0xFF6D4C41)),
  };
}
