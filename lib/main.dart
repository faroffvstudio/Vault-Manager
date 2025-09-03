// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vaultmanager/VaultConfig/environment.dart';
import 'package:vaultmanager/manager_login_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  
  try {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
  } catch (e) {
    // Handle initialization error
    print('Error initializing Supabase: $e');
  }
  
  runApp(
    const VaultManager(),
  );
}

class VaultManager extends StatelessWidget {
  const VaultManager({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: const ValueKey('vault_business_app'),
      debugShowCheckedModeBanner: false,
      title: 'Vault - Professional Accounting Software',
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
      home: const ManagerLoginScreen(),
      //home: const AdminSplashScreen(), // dont remove this
    );
  }
}
