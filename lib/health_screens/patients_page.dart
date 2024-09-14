import 'package:abtms/controllers/controllers.dart';
import 'package:abtms/health_screens/patients/patient_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PatientsPage extends StatelessWidget {
  PatientsPage({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> _getProviderCode() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot providerDoc = await _firestore
          .collection('healthcare_providers')
          .doc(user.uid)
          .get();
      if (providerDoc.exists) {
        return providerDoc['hCode'];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder<String?>(
      future: _getProviderCode(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: SpinKitThreeBounce(
                color: Color(0xFF3E4D99),
                size: 20.0,
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          String providerCode = snapshot.data!;
          return Scaffold(
            appBar: const HealthMonitoringAppbar(),
            body: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('patients')
                  .where('hCode', isEqualTo: providerCode)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SpinKitThreeBounce(
                      color: Color(0xFF3E4D99),
                      size: 20.0,
                    ),
                  );
                } else if (snapshot.hasData) {
                  List<DocumentSnapshot> patients = snapshot.data!.docs;
                  if (patients.isEmpty) {
                    return const Center(
                      child: Text('No patients found.'),
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(25),
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> patientData =
                            patients[index].data() as Map<String, dynamic>;

                        // Use a placeholder or icon if the profile image is not valid
                        Widget profileImageWidget;
                        if (patientData['profileImage'] != null &&
                            patientData['profileImage'].isNotEmpty) {
                          profileImageWidget = Image.network(
                            patientData['profileImage'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return CircleAvatar(
                                child: Center(
                                  child: const Icon(
                                    EneftyIcons.user_outline,
                                    size: 50.0,
                                    color: Color(0xFF3E4D99),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          // Default avatar if no profile image is available
                          profileImageWidget = CircleAvatar(
                            child: Center(
                              child: const Icon(
                                EneftyIcons.user_outline,
                                size: 50.0,
                                color: Color(0xFF3E4D99),
                              ),
                            ),
                          );
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientHistoryPage(
                                  patientData: patientData,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 244, 244, 255),
                              border: Border.all(
                                width: 1,
                                color: const Color.fromRGBO(224, 224, 224, 1),
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Hero(
                                  tag:
                                      'profileImage-${patientData['username']}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child:
                                          profileImageWidget, // Use the widget defined above
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patientData['fullName'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        patientData['mobileNo'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            patientData['gender'],
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child: Icon(
                                              CupertinoIcons.forward,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                } else {
                  return const Center(
                    child: Text('Error fetching patients.'),
                  );
                }
              },
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Error fetching provider code.'),
            ),
          );
        }
      },
    );
  }
}
