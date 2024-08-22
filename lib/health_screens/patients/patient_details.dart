import 'package:abtms/controllers/controllers.dart';
import 'package:abtms/health_screens/patients/profile_image.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PatientDetailPage extends StatelessWidget {
  final Map<String, dynamic> patientData;

  PatientDetailPage({required this.patientData});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: patientData['profileImage'] != null &&
                      patientData['profileImage'].isNotEmpty
                  ? NetworkImage(patientData['profileImage'])
                  : null,
              child: patientData['profileImage'] == null ||
                      patientData['profileImage'].isEmpty
                  ? const Icon(
                      EneftyIcons.user_outline,
                      size: 30.0,
                      color: Color(0xFF3E4D99),
                    )
                  : null,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              patientData['username'],
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E4D99),
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () {},
            child: Text(
              "Details",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
          // child: Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
          //   child: Column(
          //     children: [
          //       Container(
          //         height: screenHeight * 0.39,
          //         width: double.infinity,
          //         padding: EdgeInsets.all(20),
          //         decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(30),
          //             color: Colors.grey[100]),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //           children: [
          //             Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   'Full Name',
          //                   style: TextStyle(
          //                       fontSize: 15,
          //                       color: Colors.blueGrey[400],
          //                       fontWeight: FontWeight.w500),
          //                 ),
          //                 Text(
          //                   patientData['fullName'],
          //                   style: TextStyle(
          //                       fontSize: 15,
          //                       color: Colors.blueGrey,
          //                       fontWeight: FontWeight.w600),
          //                 ),
          //               ],
          //             ),
          //             Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   'Gender',
          //                   style: TextStyle(
          //                       fontSize: 15,
          //                       color: Colors.blueGrey[400],
          //                       fontWeight: FontWeight.w500),
          //                 ),
          //                 Text(
          //                   patientData['gender'],
          //                   style: TextStyle(
          //                       fontSize: 15,
          //                       color: Colors.blueGrey,
          //                       fontWeight: FontWeight.w600),
          //                 ),
          //               ],
          //             ),
          //             Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   'Email Address',
          //                   style: TextStyle(
          //                       fontSize: 15,
          //                       color: Colors.blueGrey[400],
          //                       fontWeight: FontWeight.w500),
          //                 ),
          //                 Text(
          //                   patientData['email'],
          //                   style: TextStyle(
          //                       fontSize: 15,
          //                       color: Colors.blueGrey,
          //                       fontWeight: FontWeight.w600),
          //                 ),
          //               ],
          //             ),
          //             Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   'Mobile Number',
          //                   style: TextStyle(
          //                       fontSize: 15,
          //                       color: Colors.blueGrey[400],
          //                       fontWeight: FontWeight.w500),
          //                 ),
          //                 Text(
          //                   patientData['mobileNo'],
          //                   style: TextStyle(
          //                       fontSize: 15,
          //                       color: Colors.blueGrey,
          //                       fontWeight: FontWeight.w600),
          //                 ),
          //               ],
          //             ),
          //             Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   'Address',
          //                   style: TextStyle(
          //                       fontSize: 15,
          //                       color: Colors.blueGrey[400],
          //                       fontWeight: FontWeight.w500),
          //                 ),
          //                 Text(
          //                   patientData['address'],
          //                   style: TextStyle(
          //                       fontSize: 15,
          //                       color: Colors.blueGrey,
          //                       fontWeight: FontWeight.w600),
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //       vSpace(height: 0.02),
          //       SizedBox(
          //         width: double.infinity,
          //         height: 50,
          //         child: ElevatedButton(
          //           style: ElevatedButton.styleFrom(
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(20),
          //             ),
          //             backgroundColor: Colors.black,
          //             foregroundColor: Colors.white,
          //           ),
          //           onPressed: () {},
          //           child: Text(
          //             "History",
          //             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          //           ),
          //         ),
          //       ),
          //       // Add more details about the patient here
          //     ],
          //   ),
          // ),
          ),
    );
  }
}
