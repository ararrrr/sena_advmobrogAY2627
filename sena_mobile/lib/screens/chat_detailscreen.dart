import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

final ChatService chatService = ChatService();

class ChatDetailScreen extends StatefulWidget {
  final String currentUserEmail;
  final Map<String, dynamic> tappedUser;

  const ChatDetailScreen({
    super.key,
    required this.currentUserEmail,
    required this.tappedUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _msgFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  late Future<String?> _currentUserIdFuture;
  bool _isSending = false;
  String? _pendingMessageText;
  Timestamp? _pendingMessageTime;

  static const _postSendDelay = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _currentUserIdFuture = _getCurrentUserId();
  }

  Future<String?> _getCurrentUserId() async {
    final userData = await userService.value.getUserData();
    final uid = (userData['uid'] ?? '').toString();
    if (uid.isNotEmpty) return uid;
    return userService.value.currentUser?.uid ?? '';
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String currentUserId, String receiverId) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _pendingMessageText = text;
      _pendingMessageTime = Timestamp.now();
    });

    _msgCtrl.clear();
    _msgFocus.requestFocus();

    try {
      await chatService.sendMessage(receiverId, text);

      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }

      await Future.delayed(_postSendDelay);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _pendingMessageText = null;
          _pendingMessageTime = null;
        });
      }
    }
  }

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tappedUserId = (widget.tappedUser['uid'] ?? '').toString();
    final firstName = (widget.tappedUser['firstName'] ?? '').toString();
    final lastName = (widget.tappedUser['lastName'] ?? '').toString();
    final displayName = (firstName.isNotEmpty || lastName.isNotEmpty)
        ? '$firstName $lastName'.trim()
        : (widget.tappedUser['username'] ?? 'Chat');
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return FutureBuilder<String?>(
      future: _currentUserIdFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const Center(child: Text('Error loading user data')),
          );
        }

        final currentUserId = snap.data!;

        // Automatically mark incoming messages as seen
        chatService.markMessagesAsSeen(currentUserId, tappedUserId);

        return Scaffold(
          // Enhancement 3: Modern Redesign AppBar with Avatar & Status Indicator
          appBar: AppBar(
            elevation: 1,
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 19.r,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'Active now',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          body: Column(
            children: [
              // Message Stream
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatService.getMessage(currentUserId, tappedUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator.adaptive());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: CustomText(
                          text: 'Error loading messages: ${snapshot.error}',
                          fontSize: 14.sp,
                          color: Colors.red,
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty && _pendingMessageText == null) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.sp),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 64.sp,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Say hello to $displayName!',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'No messages yet. Send the first message below.',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final totalCount = docs.length + (_pendingMessageText != null ? 1 : 0);

                    return ListView.builder(
                      controller: _scrollCtrl,
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      itemCount: totalCount,
                      itemBuilder: (context, index) {
                        // Optimistic pending message at index 0 when reverse = true
                        if (_pendingMessageText != null && index == 0) {
                          return _AnimatedMessageBubble(
                            key: const ValueKey('pending_msg'),
                            isMe: true,
                            child: _buildSenderBubble(
                              context: context,
                              message: _pendingMessageText!,
                              time: _formatTimestamp(_pendingMessageTime),
                              status: 'sending',
                            ),
                          );
                        }

                        final actualIndex = _pendingMessageText != null ? index - 1 : index;
                        final data = docs[actualIndex].data() as Map<String, dynamic>;
                        final isMe = (data['senderId'] ?? '').toString() == currentUserId;
                        final msgText = (data['message'] ?? '').toString();
                        final timestamp = data['timestamp'] as Timestamp?;
                        final status = (data['status'] ?? 'delivered').toString();
                        final docId = docs[actualIndex].id;

                        // Enhancement 3: Incorporate UI animations for message transitions (fade/slide)
                        return _AnimatedMessageBubble(
                          key: ValueKey(docId),
                          isMe: isMe,
                          child: isMe
                              ? _buildSenderBubble(
                                  context: context,
                                  message: msgText,
                                  time: _formatTimestamp(timestamp),
                                  status: status,
                                )
                              : _buildReceiverBubble(
                                  context: context,
                                  message: msgText,
                                  time: _formatTimestamp(timestamp),
                                ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Enhancement 3: Modern Redesigned Composer Bar
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.8,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: TextField(
                            controller: _msgCtrl,
                            focusNode: _msgFocus,
                            textInputAction: TextInputAction.send,
                            minLines: 1,
                            maxLines: 4,
                            onSubmitted: (_) => _send(currentUserId, tappedUserId),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Animated Send Button / Sending Spinner
                      Material(
                        color: theme.colorScheme.primary,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _isSending ? null : () => _send(currentUserId, tappedUserId),
                          child: Padding(
                            padding: EdgeInsets.all(12.r),
                            child: _isSending
                                ? SizedBox(
                                    width: 20.r,
                                    height: 20.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.send_rounded,
                                    size: 20.r,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Enhancement 3: Clearer Sender Bubble with gradients, custom corners, and Sending States
  Widget _buildSenderBubble({
    required BuildContext context,
    required String message,
    required String time,
    required String status,
  }) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(18.r),
            bottomRight: Radius.circular(4.r),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.isNotEmpty ? message : '[empty]',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
            SizedBox(height: 4.h),
            // Enhancement 3: Sending states (sending..., checkmarks for delivered/seen)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (time.isNotEmpty) ...[
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                ],
                _buildStatusIndicator(status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Enhancement 3: Clearer Receiver Bubble with modern contrast and corner styling
  Widget _buildReceiverBubble({
    required BuildContext context,
    required String message,
    required String time,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(4.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.isNotEmpty ? message : '[empty]',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
            if (time.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                time,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Enhancement 3: Status Indicator ("sending...", checkmarks for delivered/seen)
  Widget _buildStatusIndicator(String status) {
    if (status == 'sending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'sending…',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(width: 3.w),
          SizedBox(
            width: 9.r,
            height: 9.r,
            child: const CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Colors.white,
            ),
          ),
        ],
      );
    } else if (status == 'seen') {
      // Double checkmark in bright cyan for seen
      return Icon(
        Icons.done_all_rounded,
        size: 15.sp,
        color: const Color(0xFF64FFDA), // Bright cyan/teal seen indicator
      );
    } else {
      // Delivered / Sent checkmark
      return Icon(
        Icons.done_all_rounded,
        size: 15.sp,
        color: Colors.white.withValues(alpha: 0.8),
      );
    }
  }
}

// Enhancement 3: UI animations for message transitions (fade/slide)
class _AnimatedMessageBubble extends StatefulWidget {
  final Widget child;
  final bool isMe;

  const _AnimatedMessageBubble({
    super.key,
    required this.child,
    required this.isMe,
  });

  @override
  State<_AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<_AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: Offset(widget.isMe ? 0.15 : -0.15, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    ));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: widget.child,
      ),
    );
  }
}
