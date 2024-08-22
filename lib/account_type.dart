import 'package:abtms/controllers/controllers.dart';
import 'package:abtms/healthcare_provider_login_signup/login.dart';
import 'package:abtms/patient_login_signup/login.dart';
import 'package:flutter/material.dart';

class AccountSelectionPage extends StatelessWidget {
  const AccountSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo/purple_heart-removebg-preview.png",
                height: 50,
                width: 50,
              ),
              const Text(
                "abtms",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
              ),
              const Text(
                "Arduino-Based Telehealth",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3E4D99),
                  fontSize: 16,
                ),
              ),
              const Text(
                "Monitoring System",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3E4D99),
                  fontSize: 16,
                ),
              ),
              vSpace(height: 0.15),
              const Text(
                "Select your account type",
                style: TextStyle(fontSize: 17),
              ),
              const Text(
                "to continue",
                style: TextStyle(fontSize: 17),
              ),
              vSpace(height: 0.035),
              Container(
                width: 260,
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFF3E4D99),
                          ),
                        ),
                        child: const Text(
                          "Patient",
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF3E4D99),
                          ),
                        ),
                        onPressed: () {
                          // Navigator.of(context).pop();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PatientLoginPage()));
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E4D99),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // side: BorderSide(
                          //   width: 1,
                          //   color: const Color(0xFF3E4D99),
                          // ),
                        ),
                        child: const Text(
                          "Healthcare Provider",
                          style: TextStyle(fontSize: 17),
                        ),
                        onPressed: () {
                          // Navigator.of(context).pop();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HealthLoginPage()));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
