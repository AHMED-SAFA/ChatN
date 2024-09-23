import 'package:cloud_firestore/cloud_firestore.dart';

class BotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveBotChatMessage({
    required String userId,
    required Map<String, dynamic> message,
  }) async {
    await _firestore
        .collection('chats')
        .doc('botchat')
        .collection(userId)
        .doc('messages')
        .set(message);
  }

  Future<List<Map<String, dynamic>>> getBotChatMessages(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('chats')
        .doc('botchat')
        .collection(userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
