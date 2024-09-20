import 'package:abtms/authwrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the controller and animations
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );

    // Scale animation for pulsing effect
    _scaleAnimation = Tween<double>(begin: 0.5, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true); // Pulse effect for the logo

    // Start navigation to the home screen after a delay
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 4));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthWrapper(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF343F9B), // Dark blue shade
              Color.fromARGB(255, 6, 12, 80), // Darker blue shade
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale:
                          _scaleAnimation.value, // Pulsing effect for the logo
                      child: Image.asset(
                        'assets/images/logo/purple_heart-removebg-preview.png',
                        height: 40,
                        width: 40,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                const Text(
                  'abtms',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),
                // Subtle bounce effect for the loading spinner
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeInOut,
                  ),
                  child: const SpinKitThreeBounce(
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
