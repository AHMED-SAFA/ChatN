// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import '../services/auth_service.dart';
// import '../services/cloud_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final GetIt _getIt = GetIt.instance;
//   late AuthService _authService;
//   late CloudService _cloudService;
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _departmentController = TextEditingController();
//
//
//   String? _profileImageUrl;
//   bool _isEditing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _authService = _getIt.get<AuthService>();
//     _cloudService = _getIt.get<CloudService>();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     User? currentUser = _authService.user!;
//
//     if (currentUser != null) {
//       Map<String, dynamic>? userData =
//           await _cloudService.fetchLoggedInUserData(userId: currentUser.uid);
//       if (userData != null) {
//         setState(() {
//           _nameController.text = userData['name'];
//           _emailController.text = currentUser.email ?? '';
//           _departmentController.text = userData['department'];
//           _profileImageUrl = userData['profileImageUrl'];
//         });
//       }
//     }
//   }
//
//   Future<void> _updateUserData() async {
//     User? currentUser = _authService.user!;
//
//     if (currentUser != null && _passwordController.text.isNotEmpty) {
//       try {
//         // Reauthenticate user
//         AuthCredential credential = EmailAuthProvider.credential(
//           email: currentUser.email!,
//           password: _passwordController.text,
//         );
//         await currentUser.reauthenticateWithCredential(credential);
//
//         // Update data in Firestore
//         await _cloudService.storeUserData(
//           userId: currentUser.uid,
//           name: _nameController.text,
//           department: _departmentController.text,
//           profileImageUrl: _profileImageUrl ?? '',
//           activeStatus: true,
//         );
//
//         // Update email if modified
//         if (_emailController.text != currentUser.email) {
//           await currentUser.updateEmail(_emailController.text);
//         }
//
//         setState(() {
//           _isEditing = false;
//         });
//       } catch (e) {
//         // Handle errors
//         print('Error updating user: $e');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(_isEditing ? Icons.save : Icons.edit),
//             onPressed: () {
//               if (_isEditing) {
//                 _updateUserData();
//               } else {
//                 setState(() {
//                   _isEditing = true;
//                 });
//               }
//             },
//           ),
//         ],
//       ),
//       body: _profileUI(),
//     );
//   }
//
//   Widget _profileUI() {
//     return SafeArea(
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
//           child: Column(
//             children: [
//               _profileImage(),
//               _editableTextField('Name', _nameController),
//               _editableTextField('Email', _emailController),
//               _editableTextField('Password', _passwordController,
//                   isPassword: true),
//               _editableTextField('Department', _departmentController),
//               if (_isEditing)
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ElevatedButton(
//                     onPressed: _updateUserData,
//                     child: const Text('Save Changes'),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _editableTextField(String label, TextEditingController controller,
//       {bool isPassword = false}) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TextField(
//         controller: controller,
//         readOnly: !_isEditing,
//         obscureText: isPassword,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }
//
//   Widget _profileImage() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: GestureDetector(
//         onTap: _isEditing ? _selectProfileImage : null,
//         child: CircleAvatar(
//           radius: 60,
//           backgroundImage:
//               _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
//           child: _profileImageUrl == null
//               ? const Icon(Icons.person, size: 60)
//               : null,
//         ),
//       ),
//     );
//   }
//
//   Future<void> _selectProfileImage() async {}
// }

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/cloud_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late CloudService _cloudService;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  File? _newProfileImage;
  String? _profileImageUrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _cloudService = _getIt.get<CloudService>();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = _authService.user!;

    if (currentUser != null) {
      Map<String, dynamic>? userData =
          await _cloudService.fetchLoggedInUserData(userId: currentUser.uid);
      if (userData != null) {
        setState(() {
          _nameController.text = userData['name'];
          _emailController.text = currentUser.email ?? '';
          _departmentController.text =
              userData['department']; // Display but not editable
          _profileImageUrl = userData['profileImageUrl'];
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    User? currentUser = _authService.user!;

    if (currentUser != null && _passwordController.text.isNotEmpty) {
      try {
        // Reauthenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: _passwordController.text,
        );
        await currentUser.reauthenticateWithCredential(credential);

        // Update profile image if changed
        if (_newProfileImage != null) {
          String? newProfileImageUrl = await _cloudService.uploadProfileImage(
            userId: currentUser.uid,
            imageFile: _newProfileImage!,
          );
          _profileImageUrl = newProfileImageUrl;
        }

        // Update data in Firestore
        await _cloudService.storeUserData(
          userId: currentUser.uid,
          name: _nameController.text,
          department: _departmentController.text,
          profileImageUrl: _profileImageUrl ?? '',
          activeStatus: true,
        );

        // Update email if modified
        if (_emailController.text != currentUser.email) {
          await currentUser.updateEmail(_emailController.text);
        }

        // Update real-time database
        await _cloudService.storeUserDataInRealtimeDatabase(
          userId: currentUser.uid,
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          department: _departmentController.text,
        );

        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        // Handle errors
        print('Error updating user: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateUserData();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _profileUI(),
    );
  }

  Widget _profileUI() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
          child: Column(
            children: [
              _profileImage(),
              _editableTextField('Name', _nameController),
              _editableTextField('Email', _emailController),
              _editableTextField('Password', _passwordController,
                  isPassword: true),
              _nonEditableTextField('Department',
                  _departmentController), // Non-editable department field
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _updateUserData,
                    child: const Text('Save Changes'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //style
  Widget _editableTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        readOnly: !_isEditing,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  //style
  Widget _nonEditableTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        readOnly: true, // Non-editable
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _profileImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: _isEditing ? _selectProfileImage : null,
        child: CircleAvatar(
          radius: 60,
          backgroundImage: _newProfileImage != null
              ? FileImage(_newProfileImage!)
              : (_profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : null) as ImageProvider?,
          child: _profileImageUrl == null && _newProfileImage == null
              ? const Icon(Icons.person, size: 60)
              : null,
        ),
      ),
    );
  }

  Future<void> _selectProfileImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }
}
