import 'package:flutter/material.dart';
import 'show_all_food_tracker_ui.dart';

class SplashScreenUi extends StatefulWidget {
  const SplashScreenUi({super.key});

  @override
  State<SplashScreenUi> createState() => _SplashScreenUiState();
}

class _SplashScreenUiState extends State<SplashScreenUi> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ShowAllFoodTrackerUi(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF04336),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fastfood_rounded,
              size: 130,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Food Tracker',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD54F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '🍔 🍟 🌭 🍿 🍨 🧁',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 36),
            const CircularProgressIndicator(
              color: Color(0xFFFFD54F),
            ),
          ],
        ),
      ),
    );
  }
}