// import 'package:chat/services/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
//
// class login extends StatefulWidget {
//   const login({super.key});
//   @override
//   State<login> createState() => _loginState();
// }
//
// class _loginState extends State<login> {
//   final GlobalKey<FormState> _loginFormKey = GlobalKey();
//   final GetIt _getIt = GetIt.instance();
//   String? email,password;
//   late AuthService _authService;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: _buildLoginUI(),
//     );
//   }
//
//   Widget _buildLoginUI() {
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
//         child: Column(
//           children: [
//             _headerText(),
//             _formField(),
//             _regButtonText(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _headerText() {
//     return SizedBox(
//       width: MediaQuery.sizeOf(context).width,
//       child: Column(
//         mainAxisSize: MainAxisSize.max,
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Hello, Welcome",
//             style: TextStyle(
//               fontSize: 30,
//               color: Colors.black,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _formField() {
//
//     return Container(
//       height: MediaQuery.sizeOf(context).height * 0.40,
//       margin: EdgeInsets.symmetric(
//         vertical: MediaQuery.sizeOf(context).height * 0.05,
//       ),
//       child: Form(
//         key: _loginFormKey,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             _buildFormField(
//               labelText: 'Email',
//               hintText: 'Enter your email',
//               // controller: TextEditingController(),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your email';
//                 }
//                 if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                   return 'Please enter a valid email';
//                 }
//                 return null;
//               },
//             ),
//             _buildFormField(
//               labelText: 'Password',
//               hintText: 'Enter your password',
//               // controller: TextEditingController(),
//               obscureText: true,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your password';
//                 }
//                 if (value.length < 6) {
//                   return 'Password must be at least 6 characters long';
//                 }
//                 return null;
//               },
//             ),
//             _loginButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFormField({
//     required String labelText,
//     required String hintText,
//     required FormFieldValidator<String>? validator,
//     bool obscureText = false,
//   }) {
//     return TextFormField(
//       decoration: InputDecoration(
//         labelText: labelText,
//         hintText: hintText,
//         border: OutlineInputBorder(),
//       ),
//       obscureText: obscureText,
//       validator: validator,
//     );
//   }
//
//   Widget _loginButton() {
//     return SizedBox(
//       width: MediaQuery.sizeOf(context).width,
//       child: MaterialButton(
//         onPressed: () {
//           if(_loginFormKey.currentState?.validate()??false){
//           }
//         },
//         color: Theme.of(context).colorScheme.primary,
//         child: Text(
//           "Login",
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _regButtonText() {
//     return Expanded(
//       child: Row(
//         mainAxisSize: MainAxisSize.max,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text("New Here? ",style: TextStyle(fontSize: 18),),
//           Text(
//             "SignUp",
//             style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AuthService _authService;
  String? email, password;

  @override
  void initState() {
    super.initState();
    _authService = GetIt.I<AuthService>(); // Using GetIt to get the instance of AuthService
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildLoginUI(),
    );
  }

  Widget _buildLoginUI() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            _headerText(),
            _formField(),
            _regButtonText(),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, Welcome",
            style: TextStyle(
              fontSize: 30,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
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
            _loginButton(),
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

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            email = _emailController.text;
            password = _passwordController.text;
            bool success = await _authService.login(email!, password!);
            if (success) {
              // Navigate to the next screen or show success message
              print("Login Successful");
            } else {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login failed. Please try again.')),
              );
            }
          }
        },
        color: Theme.of(context).colorScheme.primary,
        child: Text(
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
          Text("New Here? ", style: TextStyle(fontSize: 18)),
          Text(
            "SignUp",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
