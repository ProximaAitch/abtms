import 'package:abtms/widgets/my_widgets.dart';
import 'package:email_validator/email_validator.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthChangePassword extends StatefulWidget {
  HealthChangePassword({super.key});

  @override
  State<HealthChangePassword> createState() => _HealthChangePasswordState();
}

class _HealthChangePasswordState extends State<HealthChangePassword> {
  final TextEditingController _emailController = TextEditingController();
  String _errorMessage = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _resetPassword() async {
    String email = _emailController.text.trim();

    setState(() {
      _errorMessage = '';
    });

    // Check if the email field is empty
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address.';
      });
      return;
    }

    // Validate the email format
    if (!EmailValidator.validate(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    // Get the current logged-in user's email
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      setState(() {
        _errorMessage = 'No user is currently logged in.';
      });
      return;
    }

    // Check if the entered email matches the currently logged-in user's email
    if (currentUser.email != email) {
      setState(() {
        _errorMessage =
            'The entered email does not match your logged-in email.';
      });
      return;
    }

    // Check if the email exists in the patients collection
    try {
      var patientSnapshot = await _firestore
          .collection('healthcare_providers')
          .where('email', isEqualTo: email)
          .get();

      if (patientSnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'No patient found with this email.';
        });
        return;
      }

      // If patient exists, attempt to send password reset email
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link has been sent to your email.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Optionally navigate after success
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }
      setState(() {
        _errorMessage = errorMessage;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
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
                  EneftyIcons.lock_outline,
                  size: 100,
                  color: Color.fromARGB(255, 167, 167, 167),
                ),
                SizedBox(height: 20),
                const Text(
                  "Please enter your email below",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),
                const Text(
                  "You will receive a change password link",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                const Text(
                  "to change your password",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 20),
                MyTextFormField(
                  hintText: "Email",
                  controller: _emailController,
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    child: const Text("Confirm"),
                    onPressed: _resetPassword,
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
