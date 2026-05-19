import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loadstock/presentation/screens/splash_screen.dart';

void main() {
  runApp(const LoadStockApp());
}

class LoadStockApp extends StatelessWidget {
  const LoadStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoadStock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
