import 'package:abtms/health_screens/settings/health_profile.dart';
import 'package:abtms/patient_screens/settings/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class vSpace extends StatelessWidget {
  final double height;

  vSpace({required this.height});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * height,
    );
  }
}

class EditTextFormField extends StatefulWidget {
  final TextEditingController controller;

  EditTextFormField({
    required this.controller,
  });

  @override
  State<EditTextFormField> createState() => _EditTextFormFieldState();
}

class _EditTextFormFieldState extends State<EditTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        fillColor: Color.fromARGB(255, 244, 244, 255),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: const BorderSide(
            width: 1,
            color: Color(0xFF3E4D99),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  MyTextFormField({
    required this.hintText,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: Color(0xFF3E4D99),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        fillColor: Colors.grey[200],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(
            color: Color(0xFF3E4D99),
            width: 1,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      ),
      validator: validator,
    );
  }
}

class PatientMonitoringAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const PatientMonitoringAppbar({super.key});

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
    return AppBar(
      toolbarHeight: 65,
      // backgroundColor: Colors.grey[100],
      automaticallyImplyLeading: false,
      title: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientProfilePage(),
                  ),
                );
              },
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    child: const Icon(
                      EneftyIcons.user_outline,
                    ),
                  ),
                  SizedBox(width: 3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome",
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        "Loading...",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientProfilePage(),
                  ),
                );
              },
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    child: const Icon(
                      EneftyIcons.user_outline,
                    ),
                  ),
                  SizedBox(width: 3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text("Error"),
                    ],
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final username = data['username'] ?? 'User';
            final profileImage = data['profileImage'] ?? '';
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientProfilePage(),
                  ),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color.fromARGB(255, 244, 244, 255),
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : null,
                    child: profileImage.isEmpty
                        ? const Icon(
                            EneftyIcons.user_outline,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        username,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: const Icon(
                    EneftyIcons.user_outline,
                  ),
                ),
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
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.bottomRight,
          child: const Text(
            "Monitoring",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3E4D99)),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}

class HealthMonitoringAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const HealthMonitoringAppbar({super.key});

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
    return AppBar(
      toolbarHeight: 65,
      // backgroundColor: Colors.grey[100],
      automaticallyImplyLeading: false,
      title: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientProfilePage(),
                  ),
                );
              },
              child: const Row(
                children: [
                  CircleAvatar(radius: 25),
                  SizedBox(width: 3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome",
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        "Loading...",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientProfilePage(),
                  ),
                );
              },
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    child: const Icon(
                      EneftyIcons.user_outline,
                    ),
                  ),
                  SizedBox(width: 3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome",
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        "Error",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final username = data['username'] ?? 'User';
            final profileImage = data['profileImage'] ?? '';
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HealthProfile(),
                  ),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : null,
                    child: profileImage.isEmpty
                        ? const Icon(
                            EneftyIcons.user_outline,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome",
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        username,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: const Icon(
                    EneftyIcons.user_outline,
                  ),
                ),
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
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.bottomRight,
          child: const Text(
            "Patients",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3E4D99),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MyAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //backgroundColor: Colors.blue,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Center(
          child: Image.asset(
            "assets/images/logo/purple_heart-removebg-preview.png",
            height: 35,
            width: 35,
            fit: BoxFit.contain,
          ),
        ),
      ),
      actions: [
        Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.bottomRight,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3E4D99),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}
