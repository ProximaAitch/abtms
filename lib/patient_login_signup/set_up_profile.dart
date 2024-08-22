import 'dart:io';

import 'package:abtms/controllers/controllers.dart';
import 'package:abtms/patient_screens/patient_widget.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetUpProfilePage extends StatefulWidget {
  SetUpProfilePage({super.key});

  @override
  State<SetUpProfilePage> createState() => _SetUpProfilePageState();
}

class _SetUpProfilePageState extends State<SetUpProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_formKey.currentState!.validate()) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String? imageUrl;
          if (_profileImage != null) {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('profile_images')
                .child('${user.uid}.jpg');
            await storageRef.putFile(_profileImage!);
            imageUrl = await storageRef.getDownloadURL();
          }
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(user.uid)
              .update({
            'username': usernameController.text.trim(),
            if (imageUrl != null) 'profileImage': imageUrl,
          });
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Good to go!',
              message: 'Profile set up successfully',
              contentType: ContentType.success,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
      }
    } catch (e) {
      print(e);
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Hmmm!',
          message: 'Error updating profile: $e',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 25,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  vSpace(height: 0.1),
                  const Center(
                    child: Text(
                      "Profile",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                    ),
                  ),
                  vSpace(height: 0.030),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(Icons.person, size: 100)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor: const Color(0xFF3E4D99),
                              foregroundColor: Colors.white,
                            ),
                            child: const Icon(Icons.camera_alt),
                            onPressed: () =>
                                _showImageSourceActionSheet(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  vSpace(height: 0.050),
                  const Text(
                    "Username",
                    style: TextStyle(
                      fontSize: 17,
                      color: Color(0xFF3E4D99),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  vSpace(height: 0.01),
                  MyTextFormField(
                    hintText: "Enter new username",
                    controller: usernameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required';
                      }
                      return null;
                    },
                  ),
                  vSpace(height: 0.050),
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF3E4D99),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              await _uploadProfile();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientWidget(),
                                ),
                              );
                            },
                      child: _isLoading
                          ? const SpinKitThreeBounce(
                              color: Colors.white,
                              size: 20.0,
                            )
                          : const Text(
                              "Finish",
                              style: TextStyle(fontSize: 17),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
