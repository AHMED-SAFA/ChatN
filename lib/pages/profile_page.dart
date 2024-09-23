import 'package:chat/services/media_service.dart';
import 'package:chat/services/navigation_service.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
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
  late NavigationService _navigationService;
  late CloudService _cloudService;
  late MediaService _mediaService;

  // Storing original values before editing
  late String _originalName = '';
  late String _originalEmail = '';
  late String _originalPassword = '';
  late String _originalDepartment = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  File? _newProfileImage;
  String? _profileImageUrl;
  bool _isEditing = false;
  bool _isClicked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _cloudService = _getIt.get<CloudService>();
    _navigationService = _getIt.get<NavigationService>();
    _mediaService = _getIt.get<MediaService>();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = _authService.user!;

    Map<String, dynamic>? userData =
        await _cloudService.fetchLoggedInUserData(userId: currentUser.uid);
    if (userData != null) {
      setState(() {
        _nameController.text = userData['name'];
        _emailController.text = currentUser.email ?? '';
        _departmentController.text = userData['department'];
        _profileImageUrl = userData['profileImageUrl'];
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    User? currentUser = _authService.user!;

    if (_passwordController.text.isNotEmpty) {
      try {
        // Reauthenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: _passwordController.text,
        );
        await currentUser.reauthenticateWithCredential(credential);

        // Update profile image if changed
        if (_newProfileImage != null) {
          String newProfileImageUrl = await _mediaService.uploadImageToStorage(
            _newProfileImage!,
            currentUser.uid,
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
          await currentUser.verifyBeforeUpdateEmail(_emailController.text);
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

        _navigationService.goBack();

        DelightToastBar(
          builder: (context) => const ToastCard(
            leading: Icon(
              Icons.offline_pin,
              size: 28,
            ),
            title: Text(
              "Successfully saved the change",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ).show(context);
      } catch (e) {
        DelightToastBar(
          builder: (context) => const ToastCard(
            leading: Icon(
              Icons.error,
              size: 28,
            ),
            title: Text(
              "Something went wrong. Try again! ", // Convert the error to a string
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ).show(context);
      }
    } else {
      DelightToastBar(
        builder: (context) => const ToastCard(
          leading: Icon(
            Icons.error,
            size: 28,
          ),
          title: Text(
            "Enter password to save change",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ).show(context);
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
                _originalName = _nameController.text;
                _originalEmail = _emailController.text;
                _originalPassword = _passwordController.text;
                _originalDepartment = _departmentController.text;

                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.all(
                    Radius.circular(6),
                  ),
                  backgroundColor: Colors.black,
                  minHeight: 10,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            )
          : _profileUI(),
    );
  }

  Widget _animatedButton({
    required VoidCallback onPressed,
    required String text,
    required Color buttonColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_isClicked ? 20.0 : 4.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.0),
        onTap: () {
          setState(() {
            _isClicked = true;
          });
          Future.delayed(const Duration(milliseconds: 800), () {
            setState(() {
              _isClicked = false;
            });
          });
          onPressed();
        },
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            elevation: 12.0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: Text(text),
        ),
      ),
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
              _nonEditableTextField('Department', _departmentController),
              if (_isEditing == true)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _animatedButton(
                        onPressed: _updateUserData,
                        text: 'Save Changes',
                        buttonColor: Colors.white60,
                      ),
                      const SizedBox(height: 15),
                      _animatedButton(
                        onPressed: _cancelEdit,
                        text: 'Cancel Edit',
                        buttonColor: Colors.white60,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // restore original values
  void _cancelEdit() {
    setState(() {
      // Restore original values
      _nameController.text = _originalName;
      _emailController.text = _originalEmail;
      _passwordController.text = _originalPassword;
      _departmentController.text = _originalDepartment;
      _isEditing = false; // Exit edit mode
    });
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

  //style
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

    // File? pickedFile = await _mediaService.getImageFromGallery();

    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }
}
