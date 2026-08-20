import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    // Enhancement 3: Render the signed-in User model on the profile screen.
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48.r,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    backgroundImage:
                        user.image.isEmpty ? null : NetworkImage(user.image),
                    child: user.image.isEmpty
                        ? Icon(Icons.person, size: 48.r)
                        : null,
                  ),
                  SizedBox(height: 14.h),
                  CustomText(
                    text: '${user.firstName} ${user.lastName}'.trim(),
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text: '@${user.username}',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(user.email),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Gender'),
                  trailing: Text(user.gender),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('User ID'),
                  trailing: Text('#${user.id}'),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          FilledButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await UserService().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
  }
}
