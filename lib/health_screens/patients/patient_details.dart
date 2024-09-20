import 'package:abtms/health_screens/patients/patient_history.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PatientDetailsPage extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const PatientDetailsPage({Key? key, required this.patientData})
      : super(key: key);

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrlString(launchUri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          patientData['username'] ?? 'Patient Details',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            const Color.fromARGB(255, 243, 245, 255),
                        backgroundImage: patientData['profileImage'] != null &&
                                patientData['profileImage'].isNotEmpty
                            ? NetworkImage(patientData['profileImage'])
                            : null,
                        child: patientData['profileImage'] == null ||
                                patientData['profileImage'].isEmpty
                            ? const Icon(
                                EneftyIcons.user_outline,
                                size: 50.0,
                                color: Color(0xFF343F9B),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text('${patientData['email'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[100],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text("Patient Details",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              color: Color(0xFF343F9B),
                            )),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF343F9B),
                        ),
                      ),
                      Text(
                        '${patientData['fullName'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      const Divider(),
                      const SizedBox(height: 5),
                      const Text('Mobile No',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF343F9B),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${patientData['mobileNo'] ?? ''}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF343F9B),
                                foregroundColor: Colors.white),
                            onPressed: () =>
                                _makePhoneCall(patientData['mobileNo'] ?? ''),
                            child: const Row(
                              children: [
                                Icon(
                                  EneftyIcons.call_bold,
                                ),
                                Text('  Call'),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Divider(),
                      const SizedBox(height: 5),
                      const Text('Gender',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF343F9B),
                          )),
                      Text('${patientData['gender'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 5),
                      const Divider(),
                      const SizedBox(height: 5),
                      const Text('Date of Birth',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF343F9B),
                          )),
                      Text('${patientData['dateOfBirth'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 5),
                      const Divider(),
                      const SizedBox(height: 5),
                      const Text('Address',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF343F9B),
                          )),
                      Text('${patientData['address'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientHistoryPage(
                          patientData: patientData,
                        ),
                      ),
                    ),
                    child: const Text("Patient History"),
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
