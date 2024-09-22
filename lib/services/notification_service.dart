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

  Future<List<Map<String, dynamic>>> retrieveNotifications({
    required String receiverId,
  }) async {
    try {
      // Fetch all notifications for the receiver from Firestore
      QuerySnapshot notificationsSnapshot = await _firebaseFirestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      // Map the data to a list of notifications
      List<Map<String, dynamic>> notifications =
          notificationsSnapshot.docs.map((doc) {
        return {
          'senderName': doc['senderName'] + '\n' + "sent you a message!\n",
          'timestamp': (doc['timestamp'] as Timestamp).toDate(),
        };
      }).toList();

      return notifications;
    } catch (e) {
      throw Exception("Could not retrieve notifications: $e");
    }
  }
}
