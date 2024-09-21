// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ActiveUserService {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Call this method when the app starts
//   Future<void> monitorUserActivity() async {
//     User? user = _firebaseAuth.currentUser;
//
//     if (user != null) {
//       await _setUserActive(user.uid, true);
//       _setUserOfflineOnDisconnect(user.uid);
//     }
//   }
//
//   Future<void> _setUserActive(String userId, bool isActive) async {
//     try {
//       await _firestore.collection('users').doc(userId).update({
//         'ActiveStatus': isActive,
//       });
//     } catch (e) {
//       throw Exception("Could not update user activity: $e");
//     }
//   }
//
//   void _setUserOfflineOnDisconnect(String userId) {
//     _firestore.collection('users').doc(userId).set({
//       'ActiveStatus': false,
//     }, SetOptions(merge: true));
//   }
//
//   // Call this method when the user logs out
//   Future<void> setUserOfflineOnLogout(String userId) async {
//     await _setUserActive(userId, false);
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveUserService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Update user active status to true (online)
  Future<void> setActive(String userId) async {
    await _firebaseFirestore.collection('users').doc(userId).update({
      'ActiveStatus': true,
    });
  }

  // Update user active status to false (offline)
  Future<void> setInactive(String userId) async {
    await _firebaseFirestore.collection('users').doc(userId).update({
      'ActiveStatus': false,
    });
  }

  // Stream that listens to the active status of all users
  Stream<Map<String, bool>> getActiveUsersStream() {
    return _firebaseFirestore.collection('users').snapshots().map((snapshot) {
      Map<String, bool> activeUsers = {};
      for (var doc in snapshot.docs) {
        activeUsers[doc.id] = doc['ActiveStatus'] ?? false;
      }
      return activeUsers;
    });
  }
}
