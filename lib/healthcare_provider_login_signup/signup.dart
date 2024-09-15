import 'package:abtms/account_type.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:abtms/widgets/my_widgets.dart';
import 'package:abtms/healthcare_provider_login_signup/login.dart';
import 'package:abtms/healthcare_provider_login_signup/auth_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HealthSignUpPage extends StatefulWidget {
  HealthSignUpPage({super.key});

  @override
  State<HealthSignUpPage> createState() => _HealthSignUpPageState();
}

class _HealthSignUpPageState extends State<HealthSignUpPage> {
  final HealthAuthService _authService = HealthAuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmpasswordController =
      TextEditingController();

  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
      return 'Confirm Password is required';
    }
    if (value != passwordController.text.trim()) {
      return 'Passwords do not match';
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
        hintText: "********",
        hintStyle:
            TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w400),
        // fillColor: Colors.grey[200],
        // filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(
            color: Color(0xFF3E4D99),
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[500],
          ),
          onPressed: _togglePasswordVisibility,
        ),
      ),
    );
  }

  Widget _confirmPasswordField(BuildContext context) {
    return TextFormField(
      controller: confirmpasswordController,
      obscureText: !_isConfirmPasswordVisible,
      validator: validateConfirmPassword,
      style: const TextStyle(
        color: Color(0xFF3E4D99),
      ),
      decoration: InputDecoration(
        hintText: "********",
        hintStyle:
            TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w400),
        // fillColor: Colors.grey[200],
        // filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(
            color: Color(0xFF3E4D99),
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[500],
          ),
          onPressed: _toggleConfirmPasswordVisibility,
        ),
      ),
    );
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
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                    ),
                    vSpace(height: 0.01),
                    const Text(
                      "Create a new account",
                      style: TextStyle(fontSize: 17),
                    ),
                    vSpace(height: 0.05),
                    const Text(
                      "Full Name",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    MyTextFormField(
                      hintText: "John Doe",
                      controller: fullNameController,
                      validator: validateFullName,
                    ),
                    vSpace(height: 0.025),
                    const Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    MyTextFormField(
                      hintText: "example@mail.com",
                      controller: emailController,
                      validator: validateEmail,
                    ),
                    vSpace(height: 0.025),
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    // MyTextFormField(
                    //   hintText: "**********",
                    //   controller: passwordController,
                    //   validator: validatePassword,
                    // ),
                    _passwordField(context),
                    vSpace(height: 0.025),
                    const Text(
                      "Confirm Password",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4D99),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    vSpace(height: 0.005),
                    // MyTextFormField(
                    //   hintText: "**********",
                    //   controller: confirmpasswordController,
                    //   validator: validateConfirmPassword,
                    // ),
                    _confirmPasswordField(context),
                    vSpace(height: 0.03),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF343F9B),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            await _authService.healthsignUpWithEmailPassword(
                              context,
                              emailController.text.trim(),
                              passwordController.text.trim(),
                              fullNameController.text.trim(),
                            );
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
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
                            // backgroundColor: Colors.black,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HealthLoginPage()),
                            );
                          },
                          child: const Text(
                            "Sign In",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // Navigator.of(context).pop();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AccountSelectionPage()));
                          },
                          child: Text("< Back"),
                        ),
                      ),
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
