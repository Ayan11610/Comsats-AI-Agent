// Main entry point for COMSATS GPT application
// This file initializes the app with Riverpod state management and GoRouter navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Main function - Entry point of the application
/// Wraps the app with ProviderScope for Riverpod state management
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Root widget of the application
/// Configures MaterialApp with custom theme and routing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // App title shown in task switcher
      title: 'COMSATS GPT',
      
      // Remove debug banner in top-right corner
      debugShowCheckedModeBanner: false,
      
      // Light theme with COMSATS purple branding
      theme: AppTheme.lightTheme,
      
      // Dark theme variant (can be toggled in settings)
      darkTheme: AppTheme.darkTheme,
      
      // Default to light mode
      themeMode: ThemeMode.light,
      
      // GoRouter configuration for navigation
      routerConfig: goRouter,
    );
  }
}
