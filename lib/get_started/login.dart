import 'dart:async';
import 'dart:io';

import 'package:abtms/get_started/signup.dart';
import 'package:abtms/health_screens/main_provider_widget.dart';
import 'package:abtms/patient_login_signup/patient_forgot_password.dart';
import 'package:abtms/patient_screens/main_patient_wrapper.dart';
import 'package:abtms/widgets/my_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  Future<String?> checkUserType(String email) async {
    try {
      // Check in patients collection
      var patientDoc = await _firestore
          .collection('patients')
          .where('email', isEqualTo: email)
          .get();
      if (patientDoc.docs.isNotEmpty) {
        return 'patient';
      }

      // Check in healthcare_providers collection
      var providerDoc = await _firestore
          .collection('healthcare_providers')
          .where('email', isEqualTo: email)
          .get();
      if (providerDoc.docs.isNotEmpty) {
        return 'healthcare_providers';
      }

      // If email is not found in either collection
      return null;
    } catch (e) {
      print('Error checking user type: $e');
      return null;
    }
  }

  Future<void> signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? userType = await checkUserType(emailController.text);

        if (userType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'User not found. Please check your email or sign up.')),
          );
          return;
        }

        // Attempt to sign in
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // If sign-in is successful, navigate to the appropriate screen
        if (userCredential.user != null) {
          if (userType == 'patient') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => MainPatientWrapper()));
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HealthProviderWrapper()));
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred. Please try again.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } on SocketException catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No internet connection. Please try again.')),
        );
      } on TimeoutException catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Connection timed out. Please try again.')),
        );
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        prefixIcon: const Icon(
          CupertinoIcons.lock_fill,
          color: Color(0xFF3E4D99),
        ),
        hintText: "Password",
        hintStyle:
            TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 132, 132, 132), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(
            color: Color(0xFF3E4D99),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E4D99),
                      ),
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
                      prefixIcon: Icons.mail,
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
                                      const PatientForgotPassword()));
                        },
                      ),
                    ),
                    vSpace(height: 0.02),
                    SizedBox(
                      height: 45,
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
                            await signIn();
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
                                    builder: (context) => SignUpPage()));
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
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
