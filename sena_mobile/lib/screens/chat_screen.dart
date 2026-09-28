import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchChatController = TextEditingController();
  final ChatService _chatService = ChatService();
  String? _currentUserEmail;
  String? _currentUserId;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _chatService.deleteUserDocByEmail('cyrus@gmail.com');
  }

  Future<void> _loadCurrentUser() async {
    final userData = await userService.value.getUserData();
    if (mounted) {
      setState(() {
        _currentUserEmail = userData['email']?.toString();
        final uid = userData['uid']?.toString() ?? '';
        _currentUserId = uid.isNotEmpty ? uid : userService.value.currentUser?.uid;
      });
    }
  }

  @override
  void dispose() {
    _searchChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messages',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Select a user to chat',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Enhancement 2: Search bar at the top of the chat list
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
            child: TextField(
              controller: _searchChatController,
              textInputAction: TextInputAction.search,
              onChanged: (val) {
                setState(() {
                  _searchText = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchChatController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _searchChatController.clear();
                            _searchText = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Users list from Firestore
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.sp),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                          SizedBox(height: 12.h),
                          CustomText(
                            text: 'Error loading users: ${snapshot.error}',
                            fontSize: 14.sp,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final rawUsers = snapshot.data ?? [];

                // Enhancement 1: Display all registered users & EXCLUDE current logged-in user
                final currentEmail = (_currentUserEmail ?? userService.value.currentUser?.email ?? '')
                    .toLowerCase()
                    .trim();
                final currentUid = (_currentUserId ?? userService.value.currentUser?.uid ?? '').trim();

                final otherUsers = rawUsers.where((u) {
                  final userEmail = (u['email'] ?? '').toString().toLowerCase().trim();
                  final userUid = (u['uid'] ?? '').toString().trim();

                  final isCurrentEmail = currentEmail.isNotEmpty && userEmail == currentEmail;
                  final isCurrentUid = currentUid.isNotEmpty && userUid == currentUid;

                  return !isCurrentEmail && !isCurrentUid;
                }).toList();

                // Enhancement 2: Filter users by name or email
                final displayedUsers = otherUsers.where((u) {
                  if (_searchText.isEmpty) return true;
                  final firstName = (u['firstName'] ?? '').toString().toLowerCase();
                  final lastName = (u['lastName'] ?? '').toString().toLowerCase();
                  final fullName = '$firstName $lastName'.trim();
                  final username = (u['username'] ?? '').toString().toLowerCase();
                  final email = (u['email'] ?? '').toString().toLowerCase();

                  return firstName.contains(_searchText) ||
                      lastName.contains(_searchText) ||
                      fullName.contains(_searchText) ||
                      username.contains(_searchText) ||
                      email.contains(_searchText);
                }).toList();

                if (otherUsers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.sp),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64.sp, color: Colors.grey.shade400),
                          SizedBox(height: 16.h),
                          CustomText(
                            text: 'No other users found',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(height: 8.h),
                          CustomText(
                            text: 'Registered users will appear here to start chatting.',
                            fontSize: 13.sp,
                            textAlign: TextAlign.center,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (displayedUsers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.sp),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 56.sp, color: Colors.grey.shade400),
                          SizedBox(height: 14.h),
                          CustomText(
                            text: 'No matches found',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                          SizedBox(height: 6.h),
                          CustomText(
                            text: 'No user found for "$_searchText"',
                            fontSize: 13.sp,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(height: 16.h),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchChatController.clear();
                                _searchText = '';
                              });
                            },
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Clear search'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: displayedUsers.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final user = displayedUsers[index];
                    final firstName = (user['firstName'] ?? '').toString();
                    final lastName = (user['lastName'] ?? '').toString();
                    final displayName = (firstName.isNotEmpty || lastName.isNotEmpty)
                        ? '$firstName $lastName'.trim()
                        : (user['username'] ?? 'User');
                    final email = (user['email'] ?? 'No email').toString();

                    final initial = displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?';

                    // Pick a pleasant background hue based on user's name
                    final avatarColor = _getAvatarColor(displayName);

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200, width: 0.8),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                currentUserEmail: _currentUserEmail ?? '',
                                tappedUser: user,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24.r,
                                backgroundColor: avatarColor,
                                child: Text(
                                  initial,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      email,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 22.sp,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue.shade600,
      Colors.indigo.shade600,
      Colors.teal.shade600,
      Colors.purple.shade600,
      Colors.deepOrange.shade600,
      Colors.cyan.shade700,
    ];
    if (name.isEmpty) return colors.first;
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
