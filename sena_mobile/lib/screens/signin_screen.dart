import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _hidePassword = true;
  String _authMethod = 'Firebase'; // 'Firebase' or 'DummyJSON'

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Enhancement 2: Custom sign-in UI connected to DummyJSON and Firebase Auth.
    final isFirebase = _authMethod == 'Firebase';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/nubdexchange_logo.png',
                        width: 58.w,
                        height: 58.w,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Welcome',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  // Segmented switch between Firebase Auth and DummyJSON
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Firebase',
                        label: Text('Firebase Auth'),
                        icon: Icon(Icons.local_fire_department),
                      ),
                      ButtonSegment(
                        value: 'DummyJSON',
                        label: Text('DummyJSON'),
                        icon: Icon(Icons.api),
                      ),
                    ],
                    selected: {_authMethod},
                    onSelectionChanged: (set) {
                      setState(() {
                        _authMethod = set.first;
                        _formKey.currentState?.reset();
                      });
                    },
                  ),
                  SizedBox(height: 28.h),
                  TextFormField(
                    controller: _identifierController,
                    keyboardType: isFirebase
                        ? TextInputType.emailAddress
                        : TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: isFirebase ? 'Email Address' : 'Username',
                      hintText: isFirebase ? 'user@example.com' : 'e.g. emilys',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(
                        isFirebase ? Icons.email_outlined : Icons.person_outline,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return isFirebase ? 'Enter your email' : 'Enter your username';
                      }
                      if (isFirebase) {
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Enter a valid email address';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    onFieldSubmitted: (_) {
                      if (!_isLoading) _login();
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _hidePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() => _hidePassword = !_hidePassword);
                        },
                        icon: Icon(
                          _hidePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your password'
                        : null,
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text('Log In with $_authMethod'),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_authMethod == 'Firebase') {
        // Sign in via Firebase Auth
        final credential = await _userService.signIn(
          email: _identifierController.text.trim(),
          password: _passwordController.text,
        );
        final fbUser = credential.user;
        if (fbUser != null) {
          final username = fbUser.displayName ?? fbUser.email?.split('@').first ?? 'Firebase User';
          await _userService.saveUserData({
            'id': 1,
            'username': username,
            'email': fbUser.email ?? '',
            'firstName': username,
            'lastName': '',
            'gender': 'N/A',
            'image': fbUser.photoURL ?? '',
            'accessToken': await fbUser.getIdToken() ?? 'firebase_token',
            'refreshToken': fbUser.refreshToken ?? '',
            'loginType': 'firebase',
          });
        }
        final userData = await _userService.getUserData();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home', arguments: userData);
      } else {
        // Sign in via DummyJSON API
        final response = await _userService.loginUser(
          _identifierController.text.trim(),
          _passwordController.text,
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home', arguments: response);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
