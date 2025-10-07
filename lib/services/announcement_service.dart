// Handles Firebase Notification and Messaging logic
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // setting message stream
  Stream<QuerySnapshot> getAnnouncementsStream() {
    return _firestore
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // post message
  Future<void> postMessage({
    required String text,
    required String userName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged in user');

    if (text.trim().isEmpty) return;

    await _firestore.collection('announcements').add({
      'text': text.trim(),
      'userId': user.uid,
      'userName': userName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

   // Toggle a reaction for the current user on a message or comment
   // Each user gets one reaction
   // Can add, remove and update reaciton here
  Future<void> toggleReaction({
    required String messageId,
    required String emoji,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final reactionRef = _firestore
        .collection('announcements')
        .doc(messageId)
        .collection('reactions')
        .doc(user.uid);

    final current = await reactionRef.get();

    if (current.exists) {
      final existingEmoji = current.data()?['emoji'];

      if (existingEmoji == emoji) {
        // User tapped the same emoji again → remove reaction
        await reactionRef.delete();
      } else {
        // User tapped a different emoji → update it
        await reactionRef.update({
          'emoji': emoji,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } else {
      // New reaction
      await reactionRef.set({
        'userId': user.uid,
        'emoji': emoji,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Stream of all reactions on a message
  Stream<List<Map<String, dynamic>>> reactionStream(String messageId) {
    return _firestore
        .collection('announcements')
        .doc(messageId)
        .collection('reactions')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }
}
