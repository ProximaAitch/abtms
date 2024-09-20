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
      style: TextStyle(
        fontWeight: FontWeight.w400,
        color: Colors.black,
        fontFamily: 'Poppins',
        fontSize: 14,
      ),
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
  final IconData? prefixIcon; // Added to allow prefix icon

  MyTextFormField({
    required this.hintText,
    required this.controller,
    this.validator,
    this.prefixIcon, // Accept prefix icon as an optional parameter
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
        hintStyle:
            TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 132, 132, 132), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(
            color: Color(0xFF3E4D99),
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Color(0xFF3E4D99),
              )
            : null, // Add prefixIcon only if it's provided
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

class UpdatedMonitoringAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const UpdatedMonitoringAppBar({super.key});

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
      backgroundColor: Color(0xFFf2f3f5),
      toolbarHeight: 65,
      automaticallyImplyLeading: false,
      title: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome",
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  "Loading...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
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
              child: const Column(
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
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final username = data['username'] ?? 'User';
            return Column(
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
            );
          } else {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome"),
                Text("User"),
              ],
            );
          }
        },
      ),
      actions: [
        FutureBuilder<Map<String, dynamic>>(
          future: fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
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
                      backgroundColor: Colors.blue,
                      backgroundImage: profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : null,
                      child: profileImage.isEmpty
                          ? const Icon(
                              EneftyIcons.user_outline,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          },
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
      automaticallyImplyLeading: false,
      title: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingTitle();
          } else if (snapshot.hasError) {
            return _buildErrorTitle();
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final username = data['username'] ?? 'User';
            return _buildUserTitle(username);
          } else {
            return _buildDefaultTitle();
          }
        },
      ),
      actions: [
        FutureBuilder<Map<String, dynamic>>(
          future: fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingAvatar(context);
            } else if (snapshot.hasError) {
              return _buildErrorAvatar(context);
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              final profileImage = data['profileImage'] ?? '';
              return _buildUserAvatar(context, profileImage);
            } else {
              return _buildDefaultAvatar(context);
            }
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildLoadingTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome", style: TextStyle(fontSize: 15)),
        Text("Loading...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildErrorTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome", style: TextStyle(fontSize: 15)),
        Text("Error", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildUserTitle(String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Welcome", style: TextStyle(fontSize: 15)),
        Text(username,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDefaultTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome", style: TextStyle(fontSize: 15)),
        Text("User", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildLoadingAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToProfile(context),
      child: const CircleAvatar(radius: 25),
    );
  }

  Widget _buildErrorAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToProfile(context),
      child: const CircleAvatar(
        radius: 25,
        child: Icon(EneftyIcons.user_outline),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, String profileImage) {
    return GestureDetector(
      onTap: () => _navigateToProfile(context),
      child: CircleAvatar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        radius: 25,
        backgroundImage:
            profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
        child:
            profileImage.isEmpty ? const Icon(EneftyIcons.user_outline) : null,
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToProfile(context),
      child: const CircleAvatar(
        radius: 25,
        child: Icon(EneftyIcons.user_outline),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthProfile(),
      ),
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
      automaticallyImplyLeading: false,
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
