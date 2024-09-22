import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Future<void> storeNotificationForMessage({
  //   required String chatId,
  //   required String loggedInUserId,
  //   required String loggedInUserName,
  //   required String receiverId,
  // }) async {
  //   try {
  //     DocumentReference notificationDoc = _firebaseFirestore
  //         .collection('users')
  //         .doc(receiverId)
  //         .collection('notifications')
  //         .doc();
  //
  //     await notificationDoc.set({
  //       'chatId': chatId,
  //       'senderName': loggedInUserName,
  //       'senderId': loggedInUserId,
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     throw Exception("Could not store notification: $e");
  //   }
  // }

  Future<String> storeNotificationForMessage({
    required String chatId,
    required String loggedInUserId,
    required String loggedInUserName,
    required String receiverId,
  }) async {
    try {
      // Create a new document reference
      DocumentReference notificationDoc = _firebaseFirestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc();

      // Store the notification data
      await notificationDoc.set({
        'chatId': chatId,
        'senderName': loggedInUserName,
        'senderId': loggedInUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Return the document ID for future reference
      return notificationDoc.id;
    } catch (e) {
      throw Exception("Could not store notification: $e");
    }
  }

  Future<List<Map<String, dynamic>>> retrieveNotifications({
    required String receiverId,
  }) async {
    try {
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
          'id': doc.id,
          'senderName': doc['senderName'] + '\n' + "sent you a message!\n",
          'timestamp': (doc['timestamp'] as Timestamp).toDate(),
        };
      }).toList();

      return notifications;
    } catch (e) {
      throw Exception("Could not retrieve notifications: $e");
    }
  }

  //delete respective notification
  Future<void> deleteNotification({
    required String receiverId,
    required String notificationId,
  }) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception("Could not delete notification: $e");
    }
  }
}
