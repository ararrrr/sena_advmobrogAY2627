import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // get all users
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // send message
  Future<void> sendMessage(String receiverId, dynamic message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String? currentUserEmail = _firebaseAuth.currentUser!.email;
    final Timestamp timestamp = Timestamp.now();
    MessageModel newMessage = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail ?? "",
      receiverId: receiverId,
      message: message.toString(),
      timestamp: timestamp,
      status: 'delivered',
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

    // add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // get message
  Stream<QuerySnapshot> getMessage(String userID, dynamic otherUserID) {
    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [userID, otherUserID.toString()];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // mark messages as seen
  Future<void> markMessagesAsSeen(String currentUserId, String otherUserId) async {
    try {
      List<String> ids = [currentUserId, otherUserId];
      ids.sort();
      String chatRoomID = ids.join('_');

      final unread = await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'delivered')
          .get();

      for (final doc in unread.docs) {
        await doc.reference.update({'status': 'seen'});
      }
    } catch (_) {}
  }

  Future<void> deleteUserDocByEmail(String email) async {
    try {
      final q = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();
      for (final doc in q.docs) {
        await doc.reference.delete();
      }
    } catch (_) {}
  }

  Future<String?> getUidByEmail(String email) async {
    final q = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    // Ensure your Users doc actually stores the Firebase Auth UID in a field 'uid'
    return (q.docs.first.data()['uid'] ?? '').toString();
  }
}
