import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;
  User? get user {
    return _user;
  }

  AuthService() {
    _firebaseAuth.authStateChanges().listen(authListener);
  }
  Future<bool> login(String email, String password) async {
    try {
      final credencial = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (credencial.user != null) {
        _user = credencial.user;
        return true;
      }
    } catch (e) {
      print(e);
      // DelightToastBar(
      //   builder: (context) => const ToastCard(
      //     leading: Icon(
      //       Icons.flutter_dash,
      //       size: 28,
      //     ),
      //     title: Text(
      //       "Error login. Try again !",
      //       style: TextStyle(
      //         fontWeight: FontWeight.w700,
      //         fontSize: 14,
      //       ),
      //     ),
      //   ),
      // ).show(context as BuildContext);
    }
    return false;
  }

  void authListener(User? user) {
    if (user != null)
      _user = user;
    else
      _user = null;
  }
}
