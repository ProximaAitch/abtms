import 'package:abtms/health_screens/settings/health_edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        backgroundColor: const Color(0xFF3E4D99),
        foregroundColor: Colors.white,
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
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthEditProfile(),
                ),
              );
            },
            child: const Text(
              "Edit",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      Container(
                        alignment: Alignment.bottomCenter,
                        height: 150,
                        color: const Color(0xFF3E4D99),
                        child: Container(
                          height: 80,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        child: Row(
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: Center(
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 55,
                                      backgroundImage: profileImage.isNotEmpty
                                          ? NetworkImage(profileImage)
                                          : null,
                                      child: profileImage.isEmpty
                                          ? const Icon(CupertinoIcons.person,
                                              size: 50)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    borderRadius: BorderRadius.circular(50),
                                    color: const Color(0xFF3E4D99),
                                  ),
                                  child: Text(
                                    username,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    borderRadius: BorderRadius.circular(50),
                                    color: const Color(0xFF3E4D99),
                                  ),
                                  child: Text(
                                    hcode,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    //height: ,
                    //color: Colors.grey,
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Personal Info",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E4D99),
                            ),
                          ),
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, bottom: 5.0),
                          child: Text(
                            "Full Name",
                            style: TextStyle(
                              color: Color(0xFF3E4D99),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          alignment: Alignment.centerLeft,
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF3F3F4),
                          ),
                          child: Text(
                            fullname,
                            style: const TextStyle(
                              fontSize: 15,
                              //fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, bottom: 5.0),
                          child: Text(
                            "Gender",
                            style: TextStyle(
                              color: Color(0xFF3E4D99),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          alignment: Alignment.centerLeft,
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF3F3F4),
                          ),
                          child: Text(
                            gender,
                            style: const TextStyle(
                              fontSize: 15,
                              //fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, bottom: 5.0),
                          child: Text(
                            "Email",
                            style: TextStyle(
                              color: Color(0xFF3E4D99),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          alignment: Alignment.centerLeft,
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF3F3F4),
                          ),
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontSize: 15,
                              //fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, bottom: 5.0),
                          child: Text(
                            "Mobile No",
                            style: TextStyle(
                              color: Color(0xFF3E4D99),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          alignment: Alignment.centerLeft,
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF3F3F4),
                          ),
                          child: Text(
                            mobileNo,
                            style: const TextStyle(
                              fontSize: 15,
                              //fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0, bottom: 5.0),
                          child: Text(
                            "Address",
                            style: TextStyle(
                              color: Color(0xFF3E4D99),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          alignment: Alignment.centerLeft,
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF3F3F4),
                          ),
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: 15,
                              //fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
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
}
