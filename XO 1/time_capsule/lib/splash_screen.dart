// This is splash_screen.dart

import 'package:flutter/material.dart';
import 'signin_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD2B48C), // same as other pages
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hourglass background (centered)
            Center(
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.hourglass_empty,
                  size: screenWidth * 0.7,
                  color: Colors.black,
                ),
              ),
            ),

            // App Name (centered in hourglass)
            Center(
              child: Text(
                "Time Capsule",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "DancingScript", // 🖋️ Fancy elegant font
                  fontSize: screenWidth * 0.13,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: const [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(1, 2),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

            // Continue Button — below hourglass (with spacing)
            Positioned(
              bottom: screenHeight * 0.08,
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.05),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (_, __, ___) => const SignInPage(),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOut,
                                ),
                              ),
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.20,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black45,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8), // space between text and arrow
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
