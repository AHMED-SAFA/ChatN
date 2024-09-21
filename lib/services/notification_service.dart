import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {


  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> storeNotificationForMessage({
    required String chatId,
    required String loggedInUserId,
    required String loggedInUserName,
    required String receiverId,
  }) async {
    try {
      DocumentReference notificationDoc = _firebaseFirestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc();

      // Store the notification details
      await notificationDoc.set({
        'chatId': chatId,
        'senderName': loggedInUserName,
        'senderId': loggedInUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Could not store notification: $e");
    }
  }
}
