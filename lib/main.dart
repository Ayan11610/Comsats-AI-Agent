// Main entry point for COMSATS AI AGENT application
// This file initializes the app with Riverpod state management and GoRouter navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/config/firebase_config.dart';
import 'core/services/gemini_service.dart';

/// Main function - Entry point of the application
/// Wraps the app with ProviderScope for Riverpod state management
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: FirebaseConfig.currentPlatform,
    );
    
    // Initialize Gemini AI service
    await GeminiService().initialize();
    
    print('✅ Firebase and Gemini AI initialized successfully');
  } catch (e) {
    print('❌ Error initializing app: $e');
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Root widget of the application
/// Configures MaterialApp with custom theme and routing
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode changes
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      // App title shown in task switcher
      title: 'COMSATS',
      
      // Remove debug banner in top-right corner
      debugShowCheckedModeBanner: false,
      
      // Light theme with COMSATS purple branding
      theme: AppTheme.lightTheme,
      
      // Dark theme variant (can be toggled in settings)
      darkTheme: AppTheme.darkTheme,
      
      // Use theme mode from provider (reactive)
      themeMode: themeMode,
      
      // GoRouter configuration for navigation
      routerConfig: goRouter,
    );
  }
}
