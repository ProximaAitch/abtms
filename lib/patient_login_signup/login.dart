import 'package:abtms/account_type.dart';
import 'package:abtms/controllers/controllers.dart';
import 'package:abtms/patient_login_signup/auth_service.dart';
import 'package:abtms/patient_login_signup/other_info.dart';
import 'package:abtms/patient_login_signup/patient_forgot_password.dart';
import 'package:abtms/patient_login_signup/signup.dart';
import 'package:abtms/patient_screens/patient_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PatientLoginPage extends StatefulWidget {
  PatientLoginPage({super.key});

  @override
  State<PatientLoginPage> createState() => _PatientLoginPageState();
}

class _PatientLoginPageState extends State<PatientLoginPage> {
  final PatientAuthService _authService = PatientAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    User? user = await _authService.signInWithGoogle();
    if (user != null) {
      final DocumentSnapshot userDoc =
          await _firestore.collection('patients').doc(user.uid).get();

      final Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;

      // Debugging log
      print('User document data: $userData');
      if (userDoc.exists &&
          userData != null &&
          userData.containsKey('address') &&
          userData.containsKey('gender') &&
          userData.containsKey('hCode') &&
          userData.containsKey('mobileNo') &&
          userData.containsKey('username')) {
        // Navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PatientWidget()), // Replace HomeScreen with your actual home screen widget
        );
      } else {
        // Navigate to AddDetailsPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  OtherInfoPage()), // Replace AddDetailsPage with your actual add details screen widget
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _passwordField(BuildContext context) {
    return TextFormField(
      controller: passwordController,
      obscureText: !_isPasswordVisible,
      validator: validatePassword,
      style: const TextStyle(
        color: Color(0xFF3E4D99),
      ),
      decoration: InputDecoration(
        hintText: "********",
        hintStyle: TextStyle(color: Colors.grey[500]),
        fillColor: Colors.grey[200],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(
            color: Color(0xFF3E4D99),
            width: 1,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[500],
          ),
          onPressed: _togglePasswordVisibility,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome back!",
                      style:
                          TextStyle(fontSize: 27, fontWeight: FontWeight.w600),
                    ),
                    vSpace(height: 0.01),
                    const Text(
                      "Sign in to continue",
                      style: TextStyle(fontSize: 17),
                    ),
                    vSpace(height: 0.07),
                    const Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    MyTextFormField(
                      hintText: "example@mail.com",
                      controller: emailController,
                      validator: validateEmail,
                    ),
                    vSpace(height: 0.020),
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    // MyTextFormField(
                    //   hintText: "**********",
                    //   controller: passwordController,
                    //   validator: validatePassword,
                    // ),
                    _passwordField(context),
                    vSpace(height: 0.01),
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: const Text("Forgot Password?"),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PatientForgotPassword()));
                        },
                      ),
                    ),
                    vSpace(height: 0.01),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF3E4D99),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            await _authService.patientsignInWithEmailPassword(
                              context,
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        child: _isLoading
                            ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 20.0,
                              )
                            : const Text(
                                "Sign In",
                                style: TextStyle(fontSize: 17),
                              ),
                      ),
                    ),
                    vSpace(height: 0.025),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          side: const BorderSide(width: 2, color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: _handleGoogleSignIn,
                        child: _isLoading
                            ? const SpinKitThreeBounce(
                                color: Color(0xFF3E4D99),
                                size: 20.0,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/logo/google_logo-removebg-preview.png",
                                    height: 35,
                                    width: 35,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text(
                                    "Continue with Google",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    vSpace(height: 0.050),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          style: TextButton.styleFrom(
                            // backgroundColor: Colors.black,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PatientSignUpPage()));
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),

                    Center(
                      child: SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // Navigator.of(context).pop();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AccountSelectionPage()));
                          },
                          child: Text("Back"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
