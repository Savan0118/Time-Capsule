import 'package:flutter/material.dart';

import 'splash_screen.dart';
import 'home_page.dart';
import 'create_memory_page.dart';
import 'view_page.dart';
import 'memory_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Capsule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.brown,
      ),

      // Start from SplashScreen, keep named routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/create': (context) => const CreateMemoryPage(mood: ''), // pass mood if you need
      },

      // Use onGenerateRoute for routes that need arguments (ViewPage expects a Memory)
      onGenerateRoute: (settings) {
        if (settings.name == '/view') {
          final args = settings.arguments;
          if (args is Memory) {
            return MaterialPageRoute(builder: (_) => ViewPage(memory: args));
          }
          // If arguments are missing or wrong type, return an error page or fallback
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Invalid arguments for /view')),
            ),
          );
        }
        return null;
      },
    );
  }
}
