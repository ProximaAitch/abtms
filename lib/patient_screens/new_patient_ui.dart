import 'package:abtms/widgets/my_widgets.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class UpdatedMonitoringPage extends StatelessWidget {
  UpdatedMonitoringPage({super.key});
  String heartrate = "72";
  String temp = "32";
  String spo2 = "94";

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFf2f3f5),
      appBar: const UpdatedMonitoringAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: screenHeight * 0.22,
                padding: EdgeInsets.all(screenHeight * 0.004),
                // color: Colors.blue,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[300],
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenHeight * 0.01),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: CircularPercentIndicator(
                          radius: screenHeight * 0.09,
                          percent: int.parse(spo2) / 100.0,
                          lineWidth: 7,
                          progressColor: Colors.blue,
                          backgroundColor: Colors.white,
                          // const Color.fromRGBO(227, 242, 253, 1),
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                spo2,
                                style: TextStyle(
                                  fontSize: screenHeight * 0.068,
                                  // textBaseline: TextBaseline.alphabetic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // SizedBox(
                              //   width: screenWidth * 0.02,
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Blood Oxidation",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // SizedBox(
                          //   height: screenHeight * 0.025,
                          // ),
                          Image.asset(
                            "assets/images/logo/blood oxidation.png",
                            height: screenHeight * 0.05,
                          ),
                          Text(
                            "%spO2",
                            style: TextStyle(
                              fontSize: screenHeight * 0.022,
                              // textBaseline: TextBaseline.alphabetic,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: screenWidth * 0.435,
                    height: screenHeight * 0.21,
                    padding: EdgeInsets.all(screenHeight * 0.004),
                    // color: Colors.blue,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[300],
                    ),
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              "assets/icons/heart-attack.png",
                              height: screenHeight * 0.035,
                              width: screenHeight * 0.035,
                            ),
                            Row(
                              // /mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline
                                  .alphabetic, // Required for baseline alignment
                              children: [
                                Text(
                                  heartrate as String,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.065,
                                    // Ensure the same TextBaseline is used
                                    textBaseline: TextBaseline.alphabetic,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.003,
                                ),
                                Text(
                                  "bpm",
                                  style: TextStyle(
                                    fontSize: screenHeight *
                                        0.022, // Adjust this based on desired size
                                    color: Colors.red,
                                    textBaseline: TextBaseline
                                        .alphabetic, // Align to the same baseline
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              "Heart Rate",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        )),
                  ),
                  Container(
                    width: screenWidth * 0.435,
                    height: screenHeight * 0.21,
                    padding: EdgeInsets.all(screenHeight * 0.004),
                    // color: Colors.blue,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[300],
                    ),
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              "assets/icons/temp icon.png",
                              height: screenHeight * 0.035,
                              width: screenHeight * 0.035,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline
                                  .alphabetic, // Required for baseline alignment
                              children: [
                                Text(
                                  temp as String,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.065,
                                    // Ensure the same TextBaseline is used
                                    textBaseline: TextBaseline.alphabetic,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.003,
                                ),
                                Text(
                                  "°C",
                                  style: TextStyle(
                                    fontSize: screenHeight *
                                        0.03, // Adjust this based on desired size
                                    color: Colors.blue,
                                    textBaseline: TextBaseline
                                        .alphabetic, // Align to the same baseline
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              "Temperature",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Container(
                width: double.infinity,
                height: screenHeight * 0.2,
                padding: EdgeInsets.all(screenHeight * 0.002),
                // color: Colors.blue,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[300],
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(screenHeight * 0.02),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text("Heart Rate is "),
                          Text(
                            "Normal",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Text("Blood Oxygen Level is "),
                          Text(
                            "Normal",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Text("Temperature is "),
                          Text(
                            "Normal",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green),
                          ),
                        ],
                      ),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("More Info"),
                            onPressed: () {},
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text("Measure"),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text("Disconnect"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
