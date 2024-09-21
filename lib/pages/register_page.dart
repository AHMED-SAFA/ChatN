import 'dart:io';
import 'package:chat/services/cloud_service.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}



class _RegisterPageState extends State<RegisterPage> {
  File? selectedImage;
  String avatar =
      "https://w7.pngwing.com/pngs/867/694/png-transparent-user-profile-default-computer-icons-network-video-recorder-avatar-cartoon-maker-blue-text-logo-thumbnail.png";
  final GetIt _getIt = GetIt.instance;
  late CloudService _cloudService;
  late NavigationService _navigationService;
  final GlobalKey<FormState> _regFormKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AuthService _authService;
  late MediaService _mediaService;
  String? email, password, name, department;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    _authService = GetIt.I<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _mediaService = _getIt.get<MediaService>();
    _cloudService = _getIt.get<CloudService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: _regUI(),
    );
  }

  Widget _regUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          children: [
            if (!isLoading) _regHeader(),
            if (!isLoading) _formField(),
            if (!isLoading) _loginButtonText(),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _regHeader() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        children: [
          Text(
            "Sign up",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Create your account",
            style: TextStyle(
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }

  Widget _formField() {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _regFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            _imagePicker(),
            const SizedBox(
              height: 30,
            ),
            _buildFormField(
              controller: _nameController,
              labelText: 'Name',
              prefixIcon: Icons.person,
              hintText: 'Enter your name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            _buildFormField(
              controller: _emailController,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              hintText: 'Enter your email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            _buildFormField(
              controller: _passwordController,
              labelText: 'Password',
              prefixIcon: Icons.password,
              hintText: 'Enter your password',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            _buildDepartmentDropdown(),
            const SizedBox(
              height: 15,
            ),
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData? prefixIcon,
    required FormFieldValidator<String>? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        fillColor: const Color(0xFFbbc6f7).withOpacity(0.1),
        filled: true,
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.black) : null,
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      value: department,
      items: _departments_name_available.map((String department) {
        return DropdownMenuItem<String>(
          value: department,
          child: Text(department),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          department = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Department',
        hintText: 'Select your department',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        fillColor: Color(0xFFbbc6f7).withOpacity(0.1),
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your department';
        }
        return null;
      },
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          if (_regFormKey.currentState?.validate() ?? false) {
            if (selectedImage == null) {
              DelightToastBar(
                builder: (context) => const ToastCard(
                  leading: Icon(
                    Icons.warning,
                    size: 28,
                  ),
                  title: Text(
                    "Please select an image!",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).show(context);
              return;
            }

            setState(() {
              isLoading = true;
            });

            try {
              email = _emailController.text;
              password = _passwordController.text;
              name = _nameController.text;
              String? selectedDepartment = department;

              // Firebase Authentication
              UserCredential userCredential =
                  await _authService.register(email!, password!);

              String? userId = userCredential.user?.uid;

              // Upload image to Firebase Storage
              String? imageUrl = await _mediaService.uploadImageToStorage(
                  selectedImage!, userId!);

              // Store user data in Firestore
              await _cloudService.storeUserData(
                activeStatus: false,
                userId: userId,
                name: name!,
                department: selectedDepartment!,
                profileImageUrl: imageUrl,
              );

              // Store user data in Realtime Database
              await _cloudService.storeUserDataInRealtimeDatabase(
                userId: userId,
                name: name!,
                email: email!,
                password: password!,
                department: selectedDepartment,
              );

              showToast(
                'You have registered!',
                context: context,
                animation: StyledToastAnimation.scale,
                reverseAnimation: StyledToastAnimation.fade,
                position: StyledToastPosition.bottom,
                animDuration: const Duration(seconds: 1),
                duration: const Duration(seconds: 4),
                curve: Curves.elasticOut,
                reverseCurve: Curves.linear,
              );
              _navigationService.pushReplacementNamed("/home");
            } catch (error) {
              DelightToastBar(
                builder: (context) => const ToastCard(
                  leading: Icon(
                    Icons.error,
                    size: 28,
                  ),
                  title: Text(
                    "Registration error. Try again!",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).show(context);
            } finally {
              setState(() {
                isLoading = false;
              });
            }
          }
        },
        color: Theme.of(context).colorScheme.primary,
        shape: const StadiumBorder(),
        child: const Text(
          "Register",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _loginButtonText() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already have an account? ",
              style: TextStyle(fontSize: 18)),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              "Login",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePicker() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: 64,
        backgroundColor: Colors.black,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(avatar) as ImageProvider,
      ),
    );
  }
}
