import 'package:abtms/widgets/my_widgets.dart';
import 'package:abtms/healthcare_provider_login_signup/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HealthForgotPassword extends StatefulWidget {
  const HealthForgotPassword({super.key});

  @override
  State<HealthForgotPassword> createState() => _HealthForgotPasswordState();
}

class _HealthForgotPasswordState extends State<HealthForgotPassword> {
  final HealthAuthService _authService = HealthAuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  String _errorMessage = '';

  void _resetPassword() async {
    try {
      await _authService.forgotPassword(
        context,
        _emailController.text.trim(),
      );
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: const Color(0xFF3E4D99),
        // foregroundColor: Colors.white,
        title: const Text(
          'Forgot Password',
          style: TextStyle(fontSize: 17),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(CupertinoIcons.back),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.lock_circle,
                  size: 100,
                  color: Color(0xFF3E4D99),
                ),
                vSpace(height: 0.02),
                const Text(
                  "Please enter your email below",
                  style: TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "You will receive a change password link",
                  style: TextStyle(
                    fontSize: 15,
                    // fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "to reset your password",
                  style: TextStyle(
                    fontSize: 15,
                    // fontWeight: FontWeight.w500,
                  ),
                ),
                vSpace(height: 0.03),
                Form(
                  key: _formKey,
                  child: MyTextFormField(
                    hintText: "Email",
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ),
                vSpace(height: 0.03),
                SizedBox(
                  height: 50,
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF3E4D99),
                    ),
                    child: const Text("Confirm"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _resetPassword();
                      }
                      ;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
