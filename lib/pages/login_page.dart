import 'package:chat/services/activeUser_service.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/navigation_service.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get_it/get_it.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late ActiveUserService _activeUserService;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AuthService _authService;
  String? email, password;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = GetIt.I<AuthService>();
    _activeUserService = GetIt.I<ActiveUserService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _loginUI(),
    );
  }

  Widget _loginUI() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            if (!isLoading) _headerText(),
            if (!isLoading) _formField(),
            if (!isLoading) _regButtonText(),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: Padding(
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
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        children: [
          Text(
            "Welcome to ChatN",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text("Enter your credential to login"),
        ],
      ),
    );
  }

  Widget _formField() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.40,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildFormField(
              controller: _emailController,
              hintText: 'Enter your email',
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
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
            _buildFormField(
              controller: _passwordController,
              hintText: 'Enter your password',
              labelText: 'Password',
              prefixIcon: Icons.password,
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
            _loginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required FormFieldValidator<String>? validator,
    required IconData? prefixIcon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        fillColor: Color(0xFFebc6f7).withOpacity(0.1),
        filled: true,
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.black) : null,
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            setState(() {
              isLoading = true;
            });
            email = _emailController.text;
            password = _passwordController.text;
            bool success = await _authService.login(email!, password!);
            if (success) {
              showToast(
                'You have logged in!',
                context: context,
                animation: StyledToastAnimation.scale,
                reverseAnimation: StyledToastAnimation.fade,
                position: StyledToastPosition.bottom,
                animDuration: Duration(seconds: 1),
                duration: Duration(seconds: 4),
                curve: Curves.elasticOut,
                reverseCurve: Curves.linear,
              );
              _activeUserService.setActive(_authService.user!.uid);
              _navigationService.pushReplacementNamed("/home");
            } else {
              DelightToastBar(
                builder: (context) => const ToastCard(
                  leading: Icon(
                    Icons.flutter_dash,
                    size: 28,
                  ),
                  title: Text(
                    "Error login. Try again !",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).show(context);
            }
          }
        },
        shape: const StadiumBorder(),
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          "Login",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _regButtonText() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account? ",
            style: TextStyle(fontSize: 18),
          ),
          GestureDetector(
            onTap: () {
              _navigationService.pushNamed("/register");
            },
            child: const Text(
              "SignUp",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
