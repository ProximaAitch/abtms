import 'package:abtms/get_started/email_verification.dart';
import 'package:abtms/get_started/login.dart';
import 'package:abtms/health_screens/main_provider_widget.dart';
import 'package:abtms/patient_screens/main_patient_wrapper.dart';
import 'package:email_validator/email_validator.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:abtms/widgets/my_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController hCodeController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _selectedUserType = 'patient';

  @override
  void initState() {
    super.initState();
    hCodeController.text = '';
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (RegExp(r'\d').hasMatch(value)) {
      return 'Full name should not contain numbers';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value?.trim() == null || value!.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain a letter and a number';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value?.trim() == null || value!.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateHCode(String? value) {
    if (_selectedUserType == 'patient') {
      if (value == null || value.isEmpty) {
        return 'hCode is required for patients';
      }
    }
    return null;
  }

  String? validateUserType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an account type';
    }
    return null;
  }

  Widget _passwordField(BuildContext context) {
    return TextFormField(
      controller: passwordController,
      obscureText: !_isPasswordVisible,
      validator: validatePassword,
      style: const TextStyle(
        color: Color(0xFF3E4D99),
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          CupertinoIcons.lock_fill,
          color: Color(0xFF3E4D99),
        ),
        hintText: "Password",
        hintStyle:
            TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w400),
        // fillColor: Colors.grey[200],
        // filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(
            color: Color(0xFF3E4D99),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[500],
          ),
          onPressed: _togglePasswordVisibility,
        ),
      ),
    );
  }

  Widget _confirmPasswordField(BuildContext context) {
    return TextFormField(
      controller: confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      validator: validateConfirmPassword,
      style: const TextStyle(
        color: Color(0xFF3E4D99),
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          CupertinoIcons.lock_fill,
          color: Color(0xFF3E4D99),
        ),
        hintText: "Confirm Password",
        hintStyle:
            TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w400),
        // fillColor: Colors.grey[200],
        // filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(
            color: Color(0xFF3E4D99),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[500],
          ),
          onPressed: _toggleConfirmPasswordVisibility,
        ),
      ),
    );
  }

  String generateHCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<bool> isHCodeValid(String hCode) async {
    QuerySnapshot query = await _firestore
        .collection('healthcare_providers')
        .where('hCode', isEqualTo: hCode)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Validate hCode for patients
        if (_selectedUserType == 'patient') {
          bool isValid = await isHCodeValid(hCodeController.text);
          if (!isValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Invalid hCode. Please check with your healthcare provider.')),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }

        // Create user with email and password
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Prepare user data
        Map<String, dynamic> userData = {
          'fullName': fullNameController.text,
          'email': emailController.text,
          'userType': _selectedUserType,
        };

        if (_selectedUserType == 'healthcare_providers') {
          userData['hCode'] = generateHCode();
        } else {
          userData['hCode'] = hCodeController.text;
        }

        // Save user data to Firestore
        await _firestore
            .collection(_selectedUserType)
            .doc(userCredential.user!.uid)
            .set(userData);

        // Navigate to appropriate screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerification(),
          ),
        );
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3E4D99),
                      ),
                    ),
                    vSpace(height: 0.01),
                    const Text(
                      "Create an account to continue",
                      style: TextStyle(fontSize: 17),
                    ),
                    vSpace(height: 0.03),
                    DropdownButtonFormField<String>(
                      value: _selectedUserType,
                      hint: const Text("Select Account Type"),
                      items: const [
                        DropdownMenuItem(
                            value: 'patient', child: Text('Patient')),
                        DropdownMenuItem(
                            value: 'healthcare_providers',
                            child: Text('Healthcare Provider')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedUserType = value!;
                          if (value == 'healthcare_providers') {
                            hCodeController.text = '';
                          }
                        });
                      },
                      validator: validateUserType,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          CupertinoIcons.person_2_fill,
                          color: Color(0xFF3E4D99),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                      ),
                    ),
                    vSpace(height: 0.020),
                    MyTextFormField(
                      hintText: "Fullname",
                      controller: fullNameController,
                      validator: validateFullName,
                      prefixIcon: CupertinoIcons.person_solid,
                    ),
                    vSpace(height: 0.020),
                    MyTextFormField(
                      hintText: "Email",
                      controller: emailController,
                      validator: validateEmail,
                      prefixIcon: Icons.mail,
                    ),
                    vSpace(height: 0.020),
                    _passwordField(context),
                    vSpace(height: 0.020),
                    _confirmPasswordField(context),
                    if (_selectedUserType == 'patient') ...[
                      vSpace(height: 0.020),
                      MyTextFormField(
                        hintText: "Healthcare Provider Code",
                        controller: hCodeController,
                        validator: validateHCode,
                        prefixIcon: Icons.health_and_safety,
                      ),
                    ],
                    vSpace(height: 0.03),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF343F9B),
                        ),
                        onPressed: signUp,
                        child: _isLoading
                            ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 20.0,
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(fontSize: 17),
                              ),
                      ),
                    ),
                    vSpace(height: 0.020),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                          child: const Text(
                            "Sign In",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
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
