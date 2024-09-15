import 'package:abtms/account_type.dart';
import 'package:abtms/widgets/my_widgets.dart';
import 'package:abtms/patient_login_signup/auth_service.dart';
import 'package:abtms/patient_login_signup/login.dart';
import 'package:abtms/patient_screens/settings/change_password.dart';
import 'package:abtms/patient_screens/settings/edit_profile.dart';
import 'package:abtms/patient_screens/settings/profile.dart';
import 'package:abtms/test/device_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class PatientSettingsPage extends StatelessWidget {
  const PatientSettingsPage({super.key});

  Future<Map<String, dynamic>> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('patients')
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
      appBar: const MyAppBar(
        title: "Settings",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: fetchUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircleAvatar(
                              backgroundColor:
                                  Color.fromARGB(255, 244, 244, 255),
                              foregroundColor: const Color(0xFF3E4D99),
                              radius: 50,
                              child: CupertinoActivityIndicator(
                                color: Colors.white,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const CircleAvatar(
                              backgroundColor:
                                  Color.fromARGB(255, 244, 244, 255),
                              foregroundColor: const Color(0xFF3E4D99),
                              radius: 50,
                              child: Icon(EneftyIcons.user_outline, size: 50),
                            );
                          } else if (snapshot.hasData) {
                            final data = snapshot.data!;
                            final profileImage = data['profileImage'] ?? '';
                            return CircleAvatar(
                              backgroundColor:
                                  Color.fromARGB(255, 244, 244, 255),
                              foregroundColor: const Color(0xFF3E4D99),
                              radius: 50,
                              backgroundImage: profileImage.isNotEmpty
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: profileImage.isEmpty
                                  ? const Icon(EneftyIcons.user_outline,
                                      size: 50)
                                  : null,
                            );
                          } else {
                            return const CircleAvatar(
                              radius: 50,
                              child: Icon(EneftyIcons.user_outline, size: 50),
                            );
                          }
                        },
                      ),
                      vSpace(height: 0.01),
                      FutureBuilder<Map<String, dynamic>>(
                        future: fetchUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Loading",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return const Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "An Error Occurred",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF676767)),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else if (snapshot.hasData) {
                            final data = snapshot.data!;
                            final username = data['username'] ?? 'Username';
                            final email = data['email'] ?? 'youremail@mail.com';
                            return Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF3E4D99),
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF676767),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            return const Row(
                              children: [
                                CircleAvatar(radius: 25),
                                SizedBox(width: 3),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Welcome"),
                                    Text("User"),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("View"),
                      const Text("Details"),
                      const SizedBox(
                        height: 3,
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 244, 244, 255),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PatientProfilePage()));
                            },
                            icon: const Icon(
                              CupertinoIcons.forward,
                              color: Color(0xFF3E4D99),
                              size: 25,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              vSpace(height: 0.015),
              Divider(
                color: Color.fromARGB(255, 221, 221, 255),
              ),
              vSpace(height: 0.015),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditPatientProfile()));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
                  width: double.infinity,
                  height: 65,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue,
                        radius: 25,
                        child: const Icon(
                          CupertinoIcons.person_fill,
                          size: 25,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Change your username, address etc",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF676767),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              vSpace(height: 0.01),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientChangePassword(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
                  width: double.infinity,
                  height: 65,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orange[50],
                        foregroundColor: Colors.orange,
                        radius: 25,
                        child: const Icon(
                          EneftyIcons.lock_outline,
                          size: 25,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Change Password",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Change your password",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF676767),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              vSpace(height: 0.01),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => DeviceListScreen(),
              //       ),
              //     );
              //   },
              //   child: Container(
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
              //     width: double.infinity,
              //     height: 65,
              //     child: Row(
              //       children: [
              //         CircleAvatar(
              //           backgroundColor: Colors.blue[50],
              //           foregroundColor: Colors.blue,
              //           radius: 25,
              //           child: const Icon(
              //             CupertinoIcons.bluetooth,
              //             size: 25,
              //           ),
              //         ),
              //         const SizedBox(
              //           width: 10,
              //         ),
              //         const Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               "Bluetooth",
              //               style: TextStyle(
              //                 fontSize: 15,
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //             Text(
              //               "Connect to bluetooth device",
              //               style: TextStyle(
              //                 fontSize: 13,
              //                 color: Color(0xFF676767),
              //               ),
              //             ),
              //           ],
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              // vSpace(height: 0.01),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
                width: double.infinity,
                height: 65,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple[50],
                      foregroundColor: Colors.purple,
                      radius: 25,
                      child: const Icon(
                        EneftyIcons.share_outline,
                        size: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Share",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Share this app with others.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF676767),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              vSpace(height: 0.01),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
                width: double.infinity,
                height: 65,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal[50],
                      foregroundColor: Colors.teal,
                      radius: 25,
                      child: const Icon(
                        EneftyIcons.info_circle_outline,
                        size: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Learn about the app",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF676767),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              vSpace(height: 0.01),
              GestureDetector(
                onTap: () {
                  QuickAlert.show(
                      context: context,
                      type: QuickAlertType.confirm,
                      confirmBtnText: "Log out",
                      confirmBtnColor: Colors.black,
                      cancelBtnText: 'No',
                      showCancelBtn: true,
                      text: 'Do you wish to log out of your account?',
                      onConfirmBtnTap: () async {
                        final PatientAuthService authService =
                            PatientAuthService();
                        await authService.signOut(context);
                        Navigator.of(context).pop();
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => AccountSelectionPage(),
                        //   ),
                        // );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const AccountSelectionPage(),
                          ),
                        );
                      });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
                  width: double.infinity,
                  height: 65,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        radius: 25,
                        child: const Icon(
                          CupertinoIcons.square_arrow_left_fill,
                          size: 25,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sign out",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Sign out of the app",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF676767),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
