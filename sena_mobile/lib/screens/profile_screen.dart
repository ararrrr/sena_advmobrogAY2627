import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    final data = await _userService.getUserData();
    if (!mounted) return;
    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _userData ?? {};
    final loginType = data['loginType'] as String? ?? 'dummyjson';
    final isFirebase = loginType == 'firebase' || _userService.currentUser != null;

    final displayName = (data['firstName'] as String? ?? '').isNotEmpty
        ? '${data['firstName']} ${data['lastName'] ?? ''}'.trim()
        : (data['username'] as String? ?? widget.user.username);
    final username = data['username'] as String? ?? widget.user.username;
    final email = data['email'] as String? ?? widget.user.email;
    final image = data['image'] as String? ?? widget.user.image;
    final userId = (data['id'] as num?)?.toInt() ??
        (widget.user.id != 0 ? widget.user.id : 1);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchUserData,
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            // User header card
            Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46.r,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      backgroundImage:
                          image.isNotEmpty ? NetworkImage(image) : null,
                      child: image.isEmpty
                          ? Icon(
                              isFirebase ? Icons.local_fire_department : Icons.person,
                              size: 46.r,
                              color: isFirebase ? Colors.orange : null,
                            )
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: displayName.isNotEmpty ? displayName : 'User',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text: '@$username',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 10.h),
                    Chip(
                      avatar: Icon(
                        isFirebase ? Icons.cloud_done : Icons.api,
                        size: 16.r,
                        color: isFirebase ? Colors.orange : Colors.blue,
                      ),
                      label: Text(
                        isFirebase ? 'Firebase Auth' : 'DummyJSON API',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // User Details (Enhancement 3)
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(email.isNotEmpty ? email : 'N/A'),
                  ),
                  const Divider(height: 1),
                  if (isFirebase)
                    const ListTile(
                      leading: Icon(Icons.perm_identity),
                      title: Text('Provider'),
                      trailing: Text('Email / Password'),
                    )
                  else
                    ListTile(
                      leading: const Icon(Icons.people_outline),
                      title: const Text('Gender'),
                      trailing: Text(widget.user.gender.isNotEmpty ? widget.user.gender : 'N/A'),
                    ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('User ID'),
                    trailing: Text('#$userId'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // Account Actions: Update username, change password, delete account (Enhancement 3)
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Update Username'),
                    subtitle: const Text('Change your display name'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showUpdateUsernameDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_reset_outlined),
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your account password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                    subtitle: const Text('Permanently remove your account'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: _showDeleteAccountDialog,
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            FilledButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateUsernameDialog() async {
    final controller = TextEditingController(text: _userData?['username'] as String? ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      try {
        if (_userService.currentUser != null) {
          await _userService.updateUsername(username: result);
        } else {
          final data = Map<String, dynamic>.from(_userData ?? {});
          data['username'] = result;
          data['firstName'] = result;
          await _userService.saveUserData(data);
        }
        await _fetchUserData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update username: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val.length < 6) return 'Must be >= 6 characters';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final email = _userData?['email'] as String? ?? _userService.currentUser?.email ?? '';
        if (_userService.currentUser != null) {
          await _userService.resetPasswordFromCurrentPassword(
            currentPassword: currentPasswordController.text,
            newPassword: newPasswordController.text,
            email: email,
          );
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password change failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action is irreversible. Enter your password to confirm account deletion:',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final email = _userData?['email'] as String? ?? _userService.currentUser?.email ?? '';
        if (_userService.currentUser != null) {
          await _userService.deleteAccount(
            email: email,
            password: passwordController.text,
          );
        } else {
          await _userService.logout();
        }
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _userService.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
  }
}
