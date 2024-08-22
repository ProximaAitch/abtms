import 'package:abtms/controllers/controllers.dart';
import 'package:abtms/health_screens/patients/profile_image.dart';
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
        title: Text(
          patientData['username'],
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E4D99),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // actions: [
        //   ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.black,
        //       foregroundColor: Colors.white,
        //     ),
        //     onPressed: () {},
        //     child: Text(
        //       "History",
        //       style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        //     ),
        //   ),
        // ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullImagePage(
                          imageUrl: patientData['profileImage'] ??
                              'https://example.com/default-profile.png',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: screenHeight * 0.38,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        patientData['profileImage'] ??
                            'https://example.com/default-profile.png',
                        height: 200,
                        width: 200,
                        //alignment: Alignment.topCenter,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                vSpace(height: 0.02),
                Container(
                  height: screenHeight * 0.39,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[100]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Name',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey[400],
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            patientData['fullName'],
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gender',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey[400],
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            patientData['gender'],
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Address',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey[400],
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            patientData['email'],
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mobile Number',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey[400],
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            patientData['mobileNo'],
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey[400],
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            patientData['address'],
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                vSpace(height: 0.02),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: Text(
                      "History",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ),
                // Add more details about the patient here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
