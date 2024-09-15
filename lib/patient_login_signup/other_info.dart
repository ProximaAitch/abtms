import 'package:abtms/widgets/my_widgets.dart';
import 'package:abtms/patient_login_signup/auth_service.dart';
import 'package:abtms/patient_login_signup/set_up_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OtherInfoPage extends StatefulWidget {
  OtherInfoPage({super.key});

  @override
  State<OtherInfoPage> createState() => _OtherInfoPageState();
}

class _OtherInfoPageState extends State<OtherInfoPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController hCodeController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String? _selectedGender;

  final PatientAuthService _authService = PatientAuthService();

  bool _isLoading = false;

  String? validateHCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your healthcare provider\'s code';
    }
    return null;
  }

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
                      "Healthcare Provider's Code",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    MyTextFormField(
                      hintText: "eg.AB1234",
                      controller: hCodeController,
                      validator: validateHCode,
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
                        // fillColor: Colors.grey[200],
                        // filled: true,
                        hintText: 'Select your gender',
                        hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color(0xFF3E4D99),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
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
                    vSpace(height: 0.01),
                    TextFormField(
                      style: const TextStyle(
                          color: Color(0xFF3E4D99), fontSize: 16),
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      validator: validateMobileNo,
                      controller: mobileNoController,
                      decoration: InputDecoration(
                        // fillColor: Colors.grey[200],
                        // filled: true,
                        hintText: "0xxxxxxxxx",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color(0xFF3E4D99),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
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
                    vSpace(height: 0.01),
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

                            // Call addInfo to add the information to Firestore
                            bool isSuccessful =
                                await _authService.patientAddInfo(
                              hCode: hCodeController.text.trim(),
                              gender: _selectedGender!,
                              mobileNo: mobileNoController.text.trim(),
                              address: addressController.text.trim(),
                              context: context,
                            );

                            setState(() {
                              _isLoading = false;
                            });

                            // Only navigate if the information was added successfully
                            if (isSuccessful) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SetUpProfilePage()),
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
