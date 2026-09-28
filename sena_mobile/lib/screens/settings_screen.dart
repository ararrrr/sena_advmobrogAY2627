import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/user_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Enhancement 3: The app-wide theme switch lives in Settings.
          Card(
            child: SwitchListTile(
              secondary: Icon(
                themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text('Dark mode'),
              subtitle: Text(
                themeProvider.isDark
                    ? 'Dark theme is enabled'
                    : 'Light theme is enabled',
              ),
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),
          SizedBox(height: 12.h),
          // Enhancement 3: Include Logout in settings -> back to login.
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Sign out and return to login screen'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Log Out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await UserService().logout();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signin',
                    (_) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

