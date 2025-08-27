import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const VaultManager());
}

class VaultManager extends StatelessWidget {
  const VaultManager({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vault Emp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}


