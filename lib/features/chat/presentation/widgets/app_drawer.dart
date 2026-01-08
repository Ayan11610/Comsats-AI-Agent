import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    return Drawer(
      child: Column(
        children: [
          // Drawer Header with COMSATS branding
          currentUserAsync.when(
            data: (user) => Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF401B5E),
                    const Color(0xFF401B5E).withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: user?.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              user!.photoURL!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/images/COMSATS.png',
                                width: 50,
                                height: 50,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/images/COMSATS.png',
                            width: 50,
                            height: 50,
                          ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(duration: 600.ms),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'COMSATS Student',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'student@comsats.edu.pk',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                ],
              ),
            ),
            loading: () => Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF401B5E),
                    const Color(0xFF401B5E).withOpacity(0.8),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            error: (error, stack) => Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF401B5E),
                    const Color(0xFF401B5E).withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'assets/images/COMSATS.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'COMSATS Student',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'student@comsats.edu.pk',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/home');
                  },
                  delay: 400,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.history,
                  title: 'History',
                  onTap: () {
                    Navigator.pop(context);
                    // Already on home which shows history
                  },
                  delay: 450,
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                  delay: 500,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                  delay: 550,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                  delay: 600,
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context, ref);
                  },
                  delay: 650,
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  'COMSATS AI Agent v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2025 COMSATS University',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    required int delay,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
            ),
      ),
      onTap: onTap,
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 400.ms)
        .slideX(begin: -0.2, end: 0, delay: delay.ms);
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use COMSATS AI Agent:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('1. Start a new conversation from the home screen'),
              SizedBox(height: 8),
              Text('2. Ask questions about your courses, assignments, or COMSATS policies'),
              SizedBox(height: 8),
              Text('3. Get AI-powered responses based on COMSATS knowledge base'),
              SizedBox(height: 16),
              Text(
                'For technical support:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Email: support@comsats.edu.pk'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About COMSATS AI Agent'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'COMSATS AI Agent is an AI-powered academic assistant designed specifically for COMSATS University students.',
              ),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Course-specific help'),
              Text('• Assignment assistance'),
              Text('• University policy information'),
              Text('• Academic guidance'),
              SizedBox(height: 16),
              Text(
                'Version: 1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('© 2024 COMSATS University'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    // Capture the auth notifier before showing the dialog
    final authNotifier = ref.read(authStateProvider.notifier);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(dialogContext);
              
              // Show loading indicator using the dialog context
              showDialog(
                context: dialogContext,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Sign out using the captured notifier
                await authNotifier.signOut();
                
                // Close loading indicator - use root navigator
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                  // Navigate to login
                  dialogContext.go('/login');
                }
              } catch (e) {
                // Close loading indicator
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                  // Show error
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
