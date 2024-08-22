import 'package:abtms/controllers/controllers.dart';
import 'package:abtms/healthcare_provider_login_signup/auth_service.dart';
import 'package:abtms/healthcare_provider_login_signup/set_up_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HealthOtherInfoPage extends StatefulWidget {
  HealthOtherInfoPage({super.key});

  @override
  State<HealthOtherInfoPage> createState() => _HealthOtherInfoPageState();
}

class _HealthOtherInfoPageState extends State<HealthOtherInfoPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController hCodeController = TextEditingController();

  TextEditingController mobileNoController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  String? _selectedGender;

  final HealthAuthService _authService = HealthAuthService();

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
                      "Gender",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    DropdownButtonFormField<String>(
                      style: TextStyle(color: Color(0xFF3E4D99), fontSize: 17),
                      value: _selectedGender,
                      validator: validateGender,
                      decoration: InputDecoration(
                        fillColor: Colors.grey[200],
                        filled: true,
                        hintText: 'Select your gender',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            width: 1,
                            color: Color(0xFF3E4D99),
                          ),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please select a gender';
                      //   }
                      //   return null;
                      // },
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
                      style: TextStyle(color: Color(0xFF3E4D99), fontSize: 16),
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      validator: validateMobileNo,
                      controller: mobileNoController,
                      decoration: InputDecoration(
                        fillColor: Colors.grey[200],
                        filled: true,
                        hintText: "0xxxxxxxxx",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            width: 1,
                            color: Color(0xFF3E4D99),
                          ),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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

                            // Call addInfo to add the information to Firestore
                            await _authService.addInfo(
                              gender: _selectedGender!,
                              mobileNo: mobileNoController.text.trim(),
                              address: addressController.text.trim(),
                            );

                            setState(() {
                              _isLoading = false;
                            });

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SetUpProfilePage()));
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
