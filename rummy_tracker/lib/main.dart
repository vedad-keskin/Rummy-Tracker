import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/layouts/splash_screen.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rummy Tracker',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
