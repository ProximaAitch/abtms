import 'package:abtms/controllers/controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

class PatientMonitoringPage extends StatefulWidget {
  final BluetoothDevice server;

  const PatientMonitoringPage({super.key, required this.server});

  @override
  _PatientMonitoringPageState createState() => _PatientMonitoringPageState();
}

class _PatientMonitoringPageState extends State<PatientMonitoringPage> {
  BluetoothConnection? connection;
  String bpm = "00"; // Default value for demonstration
  String spo2 = "00"; // Default value for demonstration
  Timer? keepAliveTimer;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  void _connectToDevice() async {
    try {
      connection = await BluetoothConnection.toAddress(widget.server.address);
      print('Connected to the device');
      listenForData();
      startKeepAlive();
    } catch (e) {
      print('Error connecting to device: $e');
      retryConnection();
    }
  }

  void sendMessage(String message) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(utf8.encode(message + "\n")));
      connection!.output.allSent.then((_) {
        print('Message sent: $message');
      }).catchError((error) {
        print('Error sending message: $error');
      });
    } else {
      print('Not connected to any device');
    }
  }

  void listenForData() {
    connection!.input!.listen((Uint8List data) {
      String receivedData = utf8.decode(data);
      print('Received data: $receivedData');

      setState(() {
        if (receivedData.contains("BPM:")) {
          bpm = receivedData.split("BPM:")[1].trim();
        } else if (receivedData.contains("SPO2:")) {
          spo2 = receivedData.split("SPO2:")[1].trim();
        }
      });
    }).onDone(() {
      print('Disconnected by remote request');
      setState(() {
        connection = null;
      });
      retryConnection();
    });
  }

  void startKeepAlive() {
    keepAliveTimer = Timer.periodic(Duration(seconds: 30), (_) {
      sendMessage('keep-alive');
    });
  }

  void retryConnection() {
    Future.delayed(Duration(seconds: 7), () {
      if (connection == null) {
        _connectToDevice();
      }
    });
  }

  @override
  void dispose() {
    keepAliveTimer?.cancel();
    connection?.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .get();
      if (docSnapshot.exists) {
        return docSnapshot.data()!;
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: const PatientMonitoringAppbar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    "Device connected",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: 15, horizontal: 0.03 * screenHeight),
                width: double.infinity,
                height: screenHeight * 0.27,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E4D99),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircularPercentIndicator(
                      radius: screenHeight * 0.11,
                      percent: int.parse(bpm) / 100.0,
                      lineWidth: 9,
                      progressColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 104, 129, 255),
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/logo/heart_rate_icon.png",
                            height: screenHeight * 0.03,
                            color: Colors.white,
                          ),
                          Text(
                            bpm,
                            style: TextStyle(
                                fontSize: screenHeight * 0.07,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                          const Text(
                            "bpm",
                            style: TextStyle(
                              color: Color(0xFFD4DBFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Heart Rate",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        ),
                        Column(
                          children: [
                            Text(
                              "beats per",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFD4DBFF),
                              ),
                            ),
                            Text(
                              "minute",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFD4DBFF),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Normal",
                          style: TextStyle(
                              color: Color(0xFFD4DBFF),
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: 15, horizontal: 0.03 * screenHeight),
                width: double.infinity,
                height: screenHeight * 0.27,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4DBFF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircularPercentIndicator(
                      radius: screenHeight * 0.11,
                      percent: int.parse(spo2) / 100.0,
                      lineWidth: 9,
                      progressColor: const Color(0xFF3E4D99),
                      backgroundColor: Colors.white,
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/logo/blood oxidation.png",
                            height: screenHeight * 0.03,
                          ),
                          Text(
                            spo2,
                            style: TextStyle(
                                fontSize: screenHeight * 0.07,
                                color: const Color(0xFF3E4D99),
                                fontWeight: FontWeight.w500),
                          ),
                          const Text(
                            "%spo2",
                            style: TextStyle(
                              color: Color(0xFF3E4D99),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Blood",
                              style: TextStyle(
                                  color: Color(0xFF3E4D99),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                            Text(
                              "Oxidation",
                              style: TextStyle(
                                  color: Color(0xFF3E4D99),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "saturation of",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF3E4D99),
                              ),
                            ),
                            Text(
                              "oxygen",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF3E4D99),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Normal",
                          style: TextStyle(
                              color: Color(0xFF3E4D99),
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(130, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF3E4D99),
                    ),
                    onPressed: () => sendMessage('measure'),
                    child: const Text("Measure"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(130, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      connection?.dispose();
                      setState(() {
                        connection = null;
                      });
                    },
                    child: const Text("Disconnect"),
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
