import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AuthService _authService;
  String? email,password;

  @override
  void initState() {
    super.initState();
    _authService = GetIt.I<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Register",),
      ),
      body: _regUI(),
    );
  }

  Widget _regUI(){
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            _formField(),
            _loginButtonText(),
          ],
        ),
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
              labelText: 'Name',
              hintText: 'Enter your name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            _buildFormField(
              controller: _emailController,
              labelText: 'Email',
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
            _buildFormField(
              controller: _passwordController,
              labelText: 'Password',
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
    required FormFieldValidator<String>? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            email = _emailController.text;
            password = _passwordController.text;
            bool success = await _authService.login(email!, password!);
            if (success) {
              showToast(
                'You have registered!',
                context: context,
                animation: StyledToastAnimation.scale,
                reverseAnimation: StyledToastAnimation.fade,
                position: StyledToastPosition.bottom,
                animDuration: Duration(seconds: 1),
                duration: Duration(seconds: 4),
                curve: Curves.elasticOut,
                reverseCurve: Curves.linear,
              );
              _navigationService.pushReplacementNamed("/login");
            }
            else {
              DelightToastBar(
                builder: (context) => const ToastCard(
                  leading: Icon(
                    Icons.flutter_dash,
                    size: 28,
                  ),
                  title: Text(
                    "Register error. Try again !",
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
        color: Theme.of(context).colorScheme.primary,
        child: Text(
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
          Text("New Here? ", style: TextStyle(fontSize: 18)),
          GestureDetector(
            onTap: () {
              _navigationService.pushNamed("/login");
            },
            child: const Text(
              "Login",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
