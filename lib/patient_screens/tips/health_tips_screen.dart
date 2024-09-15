import 'package:abtms/patient_screens/tips/chatbot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:abtms/widgets/my_widgets.dart';
import 'package:abtms/patient_screens/tips/health_tips_details.dart';

class HealthTipsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: const MyAppBar(title: 'Health Tips'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(screenHeight * 0.02),
                height: screenHeight * 0.22,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF404FC3),
                      Color(0xFF343F9B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Chat with Bot",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          "Interact with a bot for",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        const Text(
                          "more custom tips",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatBotScreen()));
                          },
                          child: const Text("Chat with Bot"),
                        ),
                      ],
                    ),
                    Image.asset(
                      "assets/images/Robot.png",
                      height: screenHeight * 0.2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                "Tap a card to generate tips on that section",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                height: screenHeight * 0.4,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Directly implemented health tip cards using Containers
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HealthTipDetailPage(
                              category: "Hydration",
                              image: "assets/images/hydration.png",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16.0),
                        width: screenWidth * 0.6,
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF085C81),
                              Color(0xFF0088C2),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Hydration",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Center(
                              child: Image.asset(
                                "assets/images/hydration.png",
                                width: screenHeight * 0.18,
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                CupertinoIcons.forward,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HealthTipDetailPage(
                              category: "Diet",
                              image: "assets/images/diet.png",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16.0),
                        width: screenWidth * 0.6,
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF006A24),
                              Color(0xFF00AA3A),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Diet",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Center(
                              child: Image.asset(
                                "assets/images/diet.png",
                                width: screenHeight * 0.2,
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                CupertinoIcons.forward,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HealthTipDetailPage(
                              category: "Personal Hygiene",
                              image: "assets/images/washing_hands.png",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16.0),
                        width: screenWidth * 0.6,
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF6421A7),
                              Color(0xFF280C43),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Hygiene",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Center(
                              child: Image.asset(
                                "assets/images/washing_hands.png",
                                width: screenHeight * 0.20,
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                CupertinoIcons.forward,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HealthTipDetailPage(
                              category: "Exercise",
                              image: "assets/images/exercise.png",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16.0),
                        width: screenWidth * 0.6,
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF085C81),
                              Color(0xFF0088C2),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Exercise",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Center(
                              child: Image.asset(
                                "assets/images/exercise.png",
                                width: screenHeight * 0.20,
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                CupertinoIcons.forward,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HealthTipDetailPage(
                              category: "Sleep",
                              image: "assets/images/sleeping.png",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16.0),
                        width: screenWidth * 0.6,
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF4E0847),
                              Color(0xFFA3669D),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Sleep",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Center(
                              child: Image.asset(
                                "assets/images/sleeping.png",
                                width: screenHeight * 0.3,
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                CupertinoIcons.forward,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
