import 'package:abtms/health_screens/health_widget.dart';
import 'package:abtms/healthcare_provider_login_signup/health_other_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abtms/widgets/my_widgets.dart';
import 'package:abtms/healthcare_provider_login_signup/auth_service.dart';
import 'package:abtms/healthcare_provider_login_signup/health_forgot_password.dart';
import 'package:abtms/healthcare_provider_login_signup/signup.dart';
import 'package:abtms/account_type.dart';

class HealthLoginPage extends StatefulWidget {
  HealthLoginPage({super.key});

  @override
  State<HealthLoginPage> createState() => _HealthLoginPageState();
}

class _HealthLoginPageState extends State<HealthLoginPage> {
  final HealthAuthService _authService = HealthAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
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
        // fillColor: Colors.grey[200],
        // filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(
            color: Color(0xFF3E4D99),
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        final DocumentSnapshot userDoc = await _firestore
            .collection('healthcare_providers')
            .doc(user.uid)
            .get();

        // Ensure the data is a Map
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
                    HealthWidget()), // Replace HomeScreen with your actual home screen widget
          );
        } else {
          // Navigate to AddDetailsPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HealthOtherInfoPage()), // Replace AddDetailsPage with your actual add details screen widget
          );
        }
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                        fontSize: 15,
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
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
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
                                      HealthForgotPassword()));
                        },
                      ),
                    ),
                    vSpace(height: 0.02),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF343F9B),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            await _authService.healthsignInWithEmailPassword(
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
                    // vSpace(height: 0.025),
                    // SizedBox(
                    //   height: 50,
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       elevation: 0,
                    //       side: const BorderSide(width: 2, color: Colors.black),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       foregroundColor: Colors.black,
                    //       backgroundColor: Colors.white,
                    //     ),
                    //     onPressed: _handleGoogleSignIn,
                    //     child: _isLoading
                    //         ? const SpinKitThreeBounce(
                    //             color: Color(0xFF3E4D99),
                    //             size: 20.0,
                    //           )
                    //         : Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Image.asset(
                    //                 "assets/images/logo/google_logo-removebg-preview.png",
                    //                 height: 35,
                    //                 width: 35,
                    //               ),
                    //               const SizedBox(
                    //                 width: 5,
                    //               ),
                    //               const Text(
                    //                 "Continue with Google",
                    //                 style: TextStyle(fontSize: 16),
                    //               ),
                    //             ],
                    //           ),
                    //   ),
                    // ),
                    vSpace(height: 0.030),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HealthSignUpPage()));
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
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
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AccountSelectionPage()));
                          },
                          child: Text("< Back"),
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
