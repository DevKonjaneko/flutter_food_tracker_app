import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'index/splash_screen_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://tvdpcvqholwbefyiskcn.supabase.co',
    anonKey: 'sb_publishable_AfV-Zn4K0rzHcyz9Vu8OXA_a23gblvr',
  );

  runApp(const FlutterFoodTrackerApp());
}
class FlutterFoodTrackerApp extends StatefulWidget {
  const FlutterFoodTrackerApp({super.key});
  @override
  State<FlutterFoodTrackerApp> createState() => _FlutterFoodTrackerAppState();
}

class _FlutterFoodTrackerAppState extends State<FlutterFoodTrackerApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreenUi(),
      theme: ThemeData(
        fontFamily: GoogleFonts.kanit().fontFamily,
        ),
      );
  }
}