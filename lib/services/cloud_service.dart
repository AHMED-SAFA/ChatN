import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  //store to cloud firestore
  Future<void> storeUserData({
    required String userId,
    required String name,
    required String department,
    required String profileImageUrl,
    required bool activeStatus,
  }) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    await userDoc.set({
      'name': name,
      'ActiveStatus': activeStatus,
      'department': department,
      'profileImageUrl': profileImageUrl,
      'userId': userId,
    });
  }

  //realtime db
  Future<void> storeUserDataInRealtimeDatabase({
    required String userId,
    required String name,
    required String email,
    required String password,
    required String department,
  }) async {
    DatabaseReference userRef = _realtimeDb.ref().child('users/$userId');
    await userRef.set({
      'name': name,
      'email': email,
      'password': password,
      'department': department,
    });
  }

  //fetch from cloud firestore
  Future<List<Map<String, dynamic>>> fetchRegisteredUsers({
    required String department,
    required String loggedInUserId,
  }) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('department', isEqualTo: department)
        .get();

    List<Map<String, dynamic>> users = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

      if (userData['userId'] != loggedInUserId) {
        users.add({
          'name': userData['name'],
          'department': userData['department'],
          'profileImageUrl': userData['profileImageUrl'],
          'userId': userData['userId'],
        });
      }
    }
    return users;
  }

  //from cloud firestore
  Future<Map<String, dynamic>?> fetchLoggedInUserData(
      {required String userId}) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  //del from everywhere
  Future<void> deleteUserAccount(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {

        //delete dp from storage
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('profileImageUrl')) {
          String profileImageUrl = userData['profileImageUrl'];

          // Delete the profile image from Firebase Storage
          Reference storageRef = _firebaseStorage.refFromURL(profileImageUrl);
          await storageRef.delete();
        }

        // Delete user data from Firestore
        await _firestore.collection('users').doc(userId).delete();

      }

      // Delete user data from Realtime Database
      await _realtimeDb.ref().child('users/$userId').remove();

      // Delete Firebase Authentication account
      User? user = _firebaseAuth.currentUser;
      if (user != null && user.uid == userId) await user.delete();
    } catch (e) {
      print("Error deleting user account: $e");
    }
  }

}
