import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class CloudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;

  Future<void> storeUserData({
    required String userId,
    required String name,
    required String profileImageUrl,
  }) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    await userDoc.set({
      'name': name,
      'profileImageUrl': profileImageUrl,
      'userId': userId,
    });
  }

  Future<void> storeUserDataInRealtimeDatabase({
    required String userId,
    required String name,
    required String email,
    required String password,
  }) async {
    DatabaseReference userRef = _realtimeDb.ref().child('users/$userId');

    await userRef.set({
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<List<Map<String, dynamic>>> fetchRegisteredUsers({
    required String loggedInUserId,
  }) async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> users = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      if (userData['userId'] != loggedInUserId) {
        users.add({
          'name': userData['name'],
          'profileImageUrl': userData['profileImageUrl'],
          'userId': userData['userId'],
        });
      }
    }

    return users;
  }


}
