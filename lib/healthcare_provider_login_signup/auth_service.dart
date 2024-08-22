import 'dart:io';
import 'dart:math';
import 'package:abtms/health_screens/health_widget.dart';
import 'package:abtms/healthcare_provider_login_signup/email_verification.dart';
import 'package:abtms/healthcare_provider_login_signup/other_info.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';

class HealthAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();


  // Sign up with email and password
  Future<User?> healthsignUpWithEmailPassword(
    BuildContext context,
    String email,
    String password,
    String fullName,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a healthcare_providers document in Firestore
      try {
        await _firestore
            .collection('healthcare_providers')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'fullName': fullName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        print(e);
      }

      // Send email verification
      await healthsendEmailVerification();

      print('Healthcare Provider signed up and added to Firestore');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Verification Email Sent Successfully!',
        onConfirmBtnTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HealthEmailVerification(),
          ),
        ),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> addInfo({
    required String gender,
    required String mobileNo,
    required String address,
  }) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No user is currently signed in.',
        );
      }

      // Generate the healthcare provider code (hCode)
      String hCode = _generateHealthcareProviderCode();

      // Add additional information to Firestore using set() with merge: true
      await _firestore.collection('healthcare_providers').doc(user.uid).set({
        'hCode': hCode,
        'gender': gender,
        'mobileNo': mobileNo,
        'address': address,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      print(e);
      // Handle any errors
      // You can also display a snackbar or dialog here to notify the user of the error
    }
  }

  String _generateHealthcareProviderCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      8,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final DocumentSnapshot userDoc = await _firestore.collection('healthcare_providers').doc(user.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection('healthcare_providers').doc(user.uid).set({
            'email': user.email,
            'fullName': user.displayName,
            'profileImage': user.photoURL,
          });
        }
      }

      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<void> healthsignInWithEmailPassword(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      // Check if the email exists in the patients collection
      QuerySnapshot healthSnapshot = await _firestore
          .collection('healthcare_providers')
          .where('email', isEqualTo: email)
          .get();

      if (healthSnapshot.docs.isEmpty) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Oops!',
            message: 'No healthcare provider found for that email.',
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        return;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Yay!',
          message: 'Healthcare Provider signed in successfully',
          contentType: ContentType.success,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HealthWidget()));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No healthcare provider found for that email.';
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Oops!',
            message: errorMessage,
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Oops!',
            message: errorMessage,
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else if (e.code == 'network-request-failed') {
        errorMessage =
            'No internet connection. Please check your network settings.';
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Oops!',
            message: errorMessage,
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else {
        errorMessage = '${e.message}';
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Oops!',
            message: errorMessage,
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Oops!',
          message: e.toString(),
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  // Send email verification
  Future<void> healthsendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print('Email verification sent');
    }
  }

  Future<void> healthcheckEmailVerification(BuildContext context) async {
    User? user = _auth.currentUser;

    if (user != null) {
      await user.reload();
      user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HealthOtherInfoPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HealthEmailVerification()),
        );
      }
    }
  }

  // Get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<Map<String, dynamic>?> healthfetchUserProfile() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No user is currently signed in.',
        );
      }

      DocumentSnapshot userDoc = await _firestore
          .collection('healthcare_providers')
          .doc(user.uid)
          .get();

      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> healthupdateUserProfile({
    required String fullName,
    required String username,
    required String gender,
    required String address,
    required String mobileNo,
   // required String hCode,
    // Add other fields as needed
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No user is currently signed in.',
        );
      }

      await _firestore.collection('healthcare_providers').doc(user.uid).update({
        'fullName': fullName,
        'username': username,
        'gender': gender,
        'address': address,
        'mobileNo': mobileNo,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> healthupdateProfileImage(XFile? profileImage) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        String? imageUrl;
        if (profileImage != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');
          await storageRef.putFile(File(profileImage.path));
          imageUrl = await storageRef.getDownloadURL();
        } else {
          imageUrl = '';
        }
        await _firestore
            .collection('healthcare_providers')
            .doc(user.uid)
            .update({
          if (imageUrl != null) 'profileImage': imageUrl,
        });
      }
    } catch (e) {
      throw e;
    }
  }




  

  Future<void> resetPassword(BuildContext context, String email) async {
    String _errorMessage = "";
    try {
      // Get the currently logged-in user
      User? user = _auth.currentUser;

      // Check if the email provided matches the current user's email
      if (user != null && user.email == email) {
        await _auth.sendPasswordResetEmail(email: email);
        _errorMessage = 'Change password email sent successfully';
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success!',
            message: _errorMessage,
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else {
        _errorMessage =
            "The provided email does not match the logged-in user's email.";
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Oops!',
            message: _errorMessage,
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      print(e.toString());
      _errorMessage = "Failed to send password reset email.$e";
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Oops!',
          message: _errorMessage,
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }


  Future<void> forgotPassword(BuildContext context, String email) async {
    String _errorMessage = "";

    try {
      // Check if the email exists in the patients collection
      QuerySnapshot patientSnapshot = await _firestore
          .collection('healthcare_providers')
          .where('email', isEqualTo: email)
          .get();

      if (patientSnapshot.docs.isNotEmpty) {
        await _auth.sendPasswordResetEmail(email: email);
        _errorMessage = 'Change password email sent successfully';
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success!',
            message: _errorMessage,
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else {
        _errorMessage = "The provided email does not exist in our records.";
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Oops!',
            message: _errorMessage,
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      print(e.toString());
      _errorMessage = "Failed to send password reset email. $e";
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Oops!',
          message: _errorMessage,
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    String _errorMessage = 'User signed out';
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Success!',
        message: _errorMessage,
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
