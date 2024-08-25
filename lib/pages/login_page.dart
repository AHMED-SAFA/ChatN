import 'package:flutter/material.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
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

  // Widget _formField() {
  //   return Container(
  //     height: MediaQuery.sizeOf(context).height * 0.40,
  //     margin: EdgeInsets.symmetric(
  //       vertical: MediaQuery.sizeOf(context).height * 0.05,
  //     ),
  //     child: Form(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisSize: MainAxisSize.max,
  //         children: [
  //
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _formField() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.40,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildFormField(
              labelText: 'Email',
              hintText: 'Enter your email',
              // controller: TextEditingController(),
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
              labelText: 'Password',
              hintText: 'Enter your password',
              // controller: TextEditingController(),
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
    required String labelText,
    required String hintText,
    required FormFieldValidator<String>? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
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
        onPressed: () {},
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
          Text("New Here? ",style: TextStyle(fontSize: 18),),
          Text(
            "SignUp",
            style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
