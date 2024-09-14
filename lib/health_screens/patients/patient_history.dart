import 'package:abtms/health_screens/patients/patient_details.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PatientHistoryPage extends StatelessWidget {
  final Map<String, dynamic> patientData;

  PatientHistoryPage({required this.patientData});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leadingWidth: screenWidth * 0.7,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: patientData['profileImage'] != null &&
                          patientData['profileImage'].isNotEmpty
                      ? NetworkImage(patientData['profileImage'])
                      : null,
                  child: patientData['profileImage'] == null ||
                          patientData['profileImage'].isEmpty
                      ? const Icon(
                          EneftyIcons.user_outline,
                          size: 22.0,
                          color: Color(0xFF3E4D99),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientDetailsPage(),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientData['username'] ?? '',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E4D99),
                        ),
                      ),
                      const Text(
                        "Tap to view details",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: const SingleChildScrollView(),
    );
  }
}
