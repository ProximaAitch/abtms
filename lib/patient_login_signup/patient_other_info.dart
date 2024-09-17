import 'package:abtms/widgets/my_widgets.dart';
import 'package:abtms/patient_login_signup/auth_service.dart';
import 'package:abtms/patient_login_signup/set_up_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class PatientAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> patientAddInfo({
    required String dateOfBirth,
    required String gender,
    required String mobileNo,
    required String address,
    required BuildContext context,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('patients').doc(user.uid).set({
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'mobileNo': mobileNo,
          'address': address,
        }, SetOptions(merge: true));
        return true;
      }
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding info: $e')),
      );
      return false;
    }
  }
}

class PatientOtherInfoPage extends StatefulWidget {
  PatientOtherInfoPage({Key? key}) : super(key: key);

  @override
  State<PatientOtherInfoPage> createState() => _PatientOtherInfoPageState();
}

class _PatientOtherInfoPageState extends State<PatientOtherInfoPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController mobileNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController dateOfBirthController =
      TextEditingController(); // Add this line

  String? _selectedGender;
  DateTime? _selectedDate; // Add this line

  final PatientAuthService _authService = PatientAuthService();

  bool _isLoading = false;

  String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a gender';
    }
    return null;
  }

  String? validateMobileNo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    } else if (value.length != 10) {
      return 'Mobile number must be 10 digits';
    } else if (!RegExp(r'^0\d{9}$').hasMatch(value)) {
      return 'Mobile number must begin with 0 and contain only digits';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your address';
    }
    return null;
  }

  String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your date of birth';
    }
    // You can add more validation if needed
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateOfBirthController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Personal Details",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                    ),
                    vSpace(height: 0.01),
                    const Text(
                      "Provide these information to continue",
                      style: TextStyle(fontSize: 17),
                    ),
                    vSpace(height: 0.06),
                    const Text(
                      "Date of Birth",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    TextFormField(
                      controller: dateOfBirthController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: validateDateOfBirth,
                      decoration: InputDecoration(
                        hintText: "Select your date of birth",
                        hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w400),
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color(0xFF3E4D99),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                      ),
                    ),
                    vSpace(height: 0.020),
                    const Text(
                      "Gender",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    DropdownButtonFormField<String>(
                      style: const TextStyle(
                          color: Color(0xFF3E4D99), fontSize: 17),
                      value: _selectedGender,
                      validator: validateGender,
                      decoration: InputDecoration(
                        hintText: 'Select your gender',
                        hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color(0xFF3E4D99),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                      ),
                      items: ['Male', 'Female']
                          .map((gender) => DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    vSpace(height: 0.020),
                    const Text(
                      "Mobile No.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    TextFormField(
                      style: const TextStyle(
                          color: Color(0xFF3E4D99), fontSize: 16),
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      validator: validateMobileNo,
                      controller: mobileNoController,
                      decoration: InputDecoration(
                        hintText: "0xxxxxxxxx",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color(0xFF3E4D99),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                      ),
                    ),
                    vSpace(height: 0.020),
                    const Text(
                      "Address",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    MyTextFormField(
                      hintText: "City, Street",
                      controller: addressController,
                      validator: validateAddress,
                    ),
                    vSpace(height: 0.05),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF3E4D99),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            // Call patientAddInfo to add the information to Firestore
                            bool isSuccessful =
                                await _authService.patientAddInfo(
                              dateOfBirth: dateOfBirthController.text.trim(),
                              gender: _selectedGender!,
                              mobileNo: mobileNoController.text.trim(),
                              address: addressController.text.trim(),
                              context: context,
                            );

                            setState(() {
                              _isLoading = false;
                            });

                            if (isSuccessful) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SetUpProfilePage(),
                                ),
                              );
                            }
                          }
                        },
                        child: _isLoading
                            ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 20.0,
                              )
                            : const Text(
                                "Next",
                                style: TextStyle(fontSize: 17),
                              ),
                      ),
                    ),
                    vSpace(height: 0.050),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
