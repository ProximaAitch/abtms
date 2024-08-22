import 'package:abtms/health_screens/settings/health_edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HealthProfile extends StatelessWidget {
  const HealthProfile({super.key});

  Future<Map<String, dynamic>> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('healthcare_providers')
          .doc(user.uid)
          .get();
      if (docSnapshot.exists) {
        return docSnapshot.data()!;
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: const Color(0xFF3E4D99),
        title: const Text(
          'Profile',
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitThreeBounce(
                color: Color(0xFF3E4D99),
                size: 20.0,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading profile'),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final profileImage = data['profileImage'] ?? '';
            final username = data['username'] ?? 'Username';
            final fullname = data['fullName'] ?? 'Fullname';
            final email = data['email'] ?? 'Email';
            final hcode = data['hCode'] ?? 'Healthcare Provider';
            final gender = data['gender'] ?? 'Gender';
            final address = data['address'] ?? 'Address';
            final mobileNo = data['mobileNo'] ?? 'Mobile No';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(255, 244, 244, 255),
                                radius: 65,
                                backgroundImage: profileImage.isNotEmpty
                                    ? NetworkImage(profileImage)
                                    : null,
                                child: profileImage.isEmpty
                                    ? const Icon(EneftyIcons.user_outline,
                                        size: 50)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3E4D99),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        color: const Color(0xFF3E4D99),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF3E4D99),
                      ),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HealthEditProfile(),
                          ),
                        );
                      },
                      child: const Text("Edit Profile"),
                    ),
                    Container(
                      //height: ,
                      //color: Colors.grey,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: Divider(
                              color: Color.fromARGB(255, 216, 216, 255),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: const Text(
                                    "Personal Info",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3E4D99),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),
                                _buildInfoRow("Full Name", fullname),
                                _buildInfoRow("Health Code", hcode),
                                _buildInfoRow("Gender", gender),
                                _buildInfoRow("Email", email),
                                _buildInfoRow("Mobile No", mobileNo),
                                _buildInfoRow("Address", address),
                                const SizedBox(
                                  height: 10,
                                ),
                                // const Center(
                                //   child: Text(
                                //     "Healthcare Provider Info",
                                //     style: TextStyle(
                                //       fontSize: 20,
                                //       fontWeight: FontWeight.w600,
                                //       color: Color(0xFF3E4D99),
                                //     ),
                                //   ),
                                // ),
                                // const Divider(),
                                // _buildInfoRow("Provider Name", providerName),
                                // _buildInfoRow("Provider Address", providerAddress),
                                // _buildInfoRow("Provider Contact", providerContact),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: Text('No data found'),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3E4D99),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          alignment: Alignment.centerLeft,
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: const Color.fromARGB(255, 244, 244, 255),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
