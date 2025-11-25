// This is mood_page.dart

import 'package:flutter/material.dart';
import 'create_memory_page.dart';

class MoodPage extends StatelessWidget {
  const MoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2B48C), // matches other pages
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text(
            "How's your mood right now?",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: "Georgia",
              fontSize: 20,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _sectionTitle("😊 Positive"),
              _moodRow([
                _moodButton(context, "Happy", const Color(0xFFFFD54F)),
                _moodButton(context, "Loving", const Color(0xFFF06292)),
              ]),
              const SizedBox(height: 12),
              _moodRow([
                _moodButton(context, "Excited", const Color(0xFFFF7043)),
                _moodButton(context, "Relaxed", const Color(0xFF4DB6AC)),
              ]),
              const SizedBox(height: 25),

              _sectionTitle("😐 Neutral"),
              _moodRow([
                _moodButton(context, "Serious", const Color(0xFF78909C)),
                _moodButton(context, "Calm", const Color(0xFF81C784)),
              ]),
              const SizedBox(height: 12),
              _moodRow([
                _moodButton(context, "Tired", const Color(0xFFCE93D8)),
                _moodButton(context, "Nostalgic", const Color(0xFFD7CCC8)),
              ]),
              const SizedBox(height: 25),

              _sectionTitle("😔 Negative"),
              _moodRow([
                _moodButton(context, "Sad", const Color(0xFF64B5F6)),
                _moodButton(context, "Angry", const Color(0xFFE57373)),
              ]),
              const SizedBox(height: 12),
              _moodRow([
                _moodButton(context, "Lonely", const Color(0xFF9575CD)),
                _moodButton(context, "Bored", const Color(0xFFBCAAA4)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: "Georgia",
        ),
      ),
    );
  }

  Widget _moodRow(List<Widget> moods) {
    return Row(
      children: [
        Expanded(child: moods[0]),
        const SizedBox(width: 16),
        Expanded(child: moods[1]),
      ],
    );
  }

  Widget _moodButton(BuildContext context, String moodText, Color color) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to CreateMemoryPage with selected mood
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateMemoryPage(mood: moodText),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          shadowColor: Colors.black45,
        ),
        child: Text(moodText, textAlign: TextAlign.center),
      ),
    );
  }
}
