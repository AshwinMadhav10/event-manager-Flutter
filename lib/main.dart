import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/login_screen.dart';
import 'utils/theme.dart';
import 'package:flutter/foundation.dart';
import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize background service for automatic booking completion
  BackgroundService.initialize();
  
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    // Suppress keyboard-related errors that are common and harmless
    final exceptionString = details.exception.toString();
    if (exceptionString.contains('KeyUpEvent') ||
        exceptionString.contains('HardwareKeyboard') ||
        exceptionString.contains('physical key is not pressed') ||
        exceptionString.contains('PhysicalKeyboardKey') ||
        exceptionString.contains('_pressedKeys.containsKey')) {
      return;
    }
    
    // Log other errors in debug mode
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lead Project',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Add a gesture detector to dismiss keyboard when tapping outside
        return GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside of text fields
            FocusScope.of(context).unfocus();
          },
          child: child!,
        );
      },
    );
  }
}
