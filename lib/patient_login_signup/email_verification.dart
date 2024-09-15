import 'package:abtms/widgets/my_widgets.dart';
import 'package:abtms/patient_login_signup/other_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'dart:async';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class PatientEmailVerification extends StatefulWidget {
  const PatientEmailVerification({super.key});

  @override
  _PatientEmailVerificationState createState() =>
      _PatientEmailVerificationState();
}

class _PatientEmailVerificationState extends State<PatientEmailVerification> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Timer _timer;
  bool _isEmailVerified = false;
  late String _email;

  @override
  void initState() {
    super.initState();
    _email = _auth.currentUser?.email ?? '';
    _isEmailVerified = _auth.currentUser!.emailVerified;
    _startEmailVerificationCheck();
  }

  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _auth.currentUser!.reload();
      var user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        setState(() {
          _isEmailVerified = true;
        });
        _showEmailVerifiedDialog();
        _timer.cancel();
      }
    });
  }

  void _sendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void goBack() {
    Navigator.pop(context);
  }

  void _showEmailVerifiedDialog() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      confirmBtnText: "Next",
      confirmBtnColor: Color(0xFF3E4D99),
      text: 'Your email has been successfully verified.',
      onConfirmBtnTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtherInfoPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Verification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/airy-receiving-mail-messages-via-email.png",
              height: 170,
              width: 170,
            ),
            vSpace(height: 0.02),
            Center(
              child: _isEmailVerified
                  ? Column(
                      children: [
                        const Text(
                          'Your email has been sucessfully verified.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF3E4D99),
                          ),
                        ),
                        vSpace(height: 0.03),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF3E4D99),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OtherInfoPage()));
                          },
                          child: const Text("Next"),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'A link has been sent to',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF3E4D99),
                              fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          'Please visit the link to verify',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        vSpace(height: 0.03),
                        const CupertinoActivityIndicator(
                          color: Color(0xFF3E4D99),
                        ),
                        vSpace(height: 0.01),
                        const Text(
                          "Waiting...",
                          style: TextStyle(fontSize: 15),
                        ),
                        vSpace(height: 0.05),
                        const Text("Didn't receive the email?"),
                        TextButton(
                          onPressed: _sendVerificationEmail,
                          child: const Text(
                            "Resend",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        vSpace(height: 0.02),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black,
                          ),
                          onPressed: goBack,
                          child: const Text("Go Back"),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
