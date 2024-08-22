import 'dart:io';

import 'package:abtms/controllers/controllers.dart';
import 'package:abtms/healthcare_provider_login_signup/auth_service.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HealthEditProfile extends StatefulWidget {
  const HealthEditProfile({super.key});

  @override
  State<HealthEditProfile> createState() => _HealthEditProfileState();
}

class _HealthEditProfileState extends State<HealthEditProfile> {
  TextEditingController usernameController = TextEditingController();

  TextEditingController fullnameController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  TextEditingController mobileNoController = TextEditingController();

  // TextEditingController hCodeController = TextEditingController();

  String email = '';

  String selectedGender = 'Male';

  final List<String> genderOptions = ['Male', 'Female'];

  final ImagePicker _picker = ImagePicker();

  XFile? _profileImage;

  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    HealthAuthService authService = HealthAuthService();
    print("Fetching user profile...");
    Map<String, dynamic>? userProfile =
        await authService.healthfetchUserProfile();

    if (userProfile != null) {
      print("User profile fetched successfully: $userProfile");
      setState(() {
        fullnameController.text = userProfile['fullName'] ?? '';
        email = userProfile['email'] ?? '';
        usernameController.text = userProfile['username'] ?? '';
        addressController.text = userProfile['address'] ?? '';
        mobileNoController.text = userProfile['mobileNo'] ?? '';
        // hCodeController.text = userProfile['hCode'] ?? '';
        selectedGender = userProfile['gender'] ?? 'Male';
        profileImageUrl = userProfile['profileImage'] ?? '';
      });
    } else {
      print("Failed to load user profile.");
      if (mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Oops!',
            message: 'Failed to load user profile',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    }
  }

  Future<void> updateUserProfile() async {
    HealthAuthService authService = HealthAuthService();
    await authService.healthupdateUserProfile(
      fullName: fullnameController.text.trim(),
      username: usernameController.text.trim(),
      gender: selectedGender,
      address: addressController.text.trim(),
      mobileNo: mobileNoController.text.trim(),
      //hCode: hCodeController.text.trim(),
    );
    if (mounted) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Good to go!',
          message: 'Profile updated successfully',
          contentType: ContentType.success,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
        await HealthAuthService().healthupdateProfileImage(pickedFile);
        await fetchUserProfile();
        if (mounted) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Good to go!',
              message: 'Profile image updated successfully',
              contentType: ContentType.success,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
      }
    } catch (e) {
      if (mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Oops!',
            message: 'Error updating profile image: $e',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove'),
                  onTap: () async {
                    setState(() {
                      _profileImage = null;
                      profileImageUrl = '';
                    });
                    await HealthAuthService().healthupdateProfileImage(null);
                    if (mounted) {}
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: const Color(0xFF3E4D99),
        title: const Text(
          'Edit Profile',
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
              await updateUserProfile();
              Navigator.of(context).pop();
            },
            child: const Text(
              "Done",
              style: TextStyle(
                  color: Color(0xFF3E4D99),
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 244, 244, 255),
                          radius: 70,
                          backgroundImage: _profileImage != null
                              ? FileImage(File(_profileImage!.path))
                              : profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : null as ImageProvider<Object>?,
                          child:
                              _profileImage == null && profileImageUrl.isEmpty
                                  ? const Icon(
                                      EneftyIcons.user_outline,
                                      size: 70,
                                    )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: -5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor: const Color(0xFF3E4D99),
                              foregroundColor: Colors.white,
                            ),
                            child: const Icon(Icons.camera_alt),
                            onPressed: _showImageOptions,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              email,
              style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF3E4D99),
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15.0, bottom: 5),
                    child: Text(
                      "Full Name",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  EditTextFormField(
                    controller: fullnameController,
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 15.0, bottom: 5),
                    child: Text(
                      "Username",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                      ),
                    ),
                  ),
                  EditTextFormField(
                    controller: usernameController,
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 15.0, bottom: 5),
                    child: Text(
                      "Gender",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    borderRadius: BorderRadius.circular(50.0),
                    decoration: InputDecoration(
                      fillColor: Color.fromARGB(255, 244, 244, 255),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: selectedGender,
                    items: genderOptions
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 15.0, bottom: 5),
                    child: Text(
                      "Address",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  EditTextFormField(
                    controller: addressController,
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 15.0, bottom: 5),
                    child: Text(
                      "Mobile No.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  EditTextFormField(
                    controller: mobileNoController,
                  ),
                  // const SizedBox(height: 20),
                  // const Padding(
                  //   padding: EdgeInsets.only(left: 15.0, bottom: 5),
                  //   child: Text(
                  //     "Healthcare Provider's Code",
                  //     style: TextStyle(
                  //       fontSize: 15,
                  //       color: Color(0xFF3E4D99),
                  //     ),
                  //   ),
                  // ),
                  // EditTextFormField(
                  //   controller: hCodeController,
                  // ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
