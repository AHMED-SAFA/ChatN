import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String> createOrGetChat({
    required String userId1,
    required String userId2,
    required String name1,
    required String name2,
  }) async {
    try {
      List<String> userIds = [userId1, userId2];
      List<String> names = [name1, name2];
      userIds.sort();
      String chatId = userIds.join('_');

      // Check if chat already exists
      DocumentReference chatDoc = _firebaseFirestore.collection('chats').doc(chatId);
      DocumentSnapshot chatSnapshot = await chatDoc.get();

      if (!chatSnapshot.exists) {
        // If chat doesn't exist, create a new chat document
        await chatDoc.set({
          'chatId': chatId,
          'participants': userIds,
          'names': names,
          'messages': [],
        });
      }
      return chatId;
    } catch (e) {
      throw Exception("Could not create or get chat");
    }
  }





}
