// lib/main.dart
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'home_page.dart';
import 'create_memory_page.dart';
import 'view_page.dart';
// import memory_model with a prefix to avoid ambiguous 'Memory' symbol
import 'memory_model.dart' as mem;
// import session_manager with a prefix so SessionManager is referenced unambiguously
import 'session_manager.dart' as session;
import 'signin_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // call via prefix to ensure analyzer finds it
  final bool loggedIn = await session.SessionManager.isLoggedIn();
  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Capsule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.brown,
      ),

      // If the user is logged in, start at /home; otherwise start at splash.
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/create': (context) => const CreateMemoryPage(mood: ''),
        '/signin': (context) => const SignInPage(),
      },

      // Use onGenerateRoute for routes that need arguments (ViewPage expects a mem.Memory)
      onGenerateRoute: (settings) {
        if (settings.name == '/view') {
          final args = settings.arguments;
          if (args is mem.Memory) {
            // pass the typed Memory to ViewPage
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
