import 'package:abtms/account_type.dart';
import 'package:abtms/get_started/login.dart';
import 'package:abtms/health_screens/health_widget.dart';
import 'package:abtms/health_screens/main_provider_widget.dart';
import 'package:abtms/patient_screens/main_patient_wrapper.dart';
import 'package:abtms/patient_screens/patient_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<String?> _getUserRole(String uid) async {
    DocumentSnapshot healthcareProviderDoc = await FirebaseFirestore.instance
        .collection('healthcare_providers')
        .doc(uid)
        .get();
    if (healthcareProviderDoc.exists) {
      return 'healthcare_provider';
    }

    DocumentSnapshot patientDoc =
        await FirebaseFirestore.instance.collection('patients').doc(uid).get();
    if (patientDoc.exists) {
      return 'patient';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Hang tight...",
                    style: TextStyle(
                      fontSize: 17,
                      color: Color(0xFF3E4D99),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SpinKitThreeBounce(
                    color: Color(0xFF3E4D99),
                    size: 25.0,
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: _getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hang tight...",
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF3E4D99),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SpinKitThreeBounce(
                          color: Color(0xFF3E4D99),
                          size: 25.0,
                        ),
                      ],
                    ),
                  ),
                );
              } else if (roleSnapshot.hasData) {
                final role = roleSnapshot.data;

                if (role == 'patient') {
                  return MainPatientWrapper();
                } else if (role == 'healthcare_provider') {
                  return HealthProviderWrapper();
                } else {
                  return LoginPage();
                }
              } else {
                return LoginPage();
              }
            },
          );
        } else {
          return LoginPage();
        }
      },
    );
  }
}
