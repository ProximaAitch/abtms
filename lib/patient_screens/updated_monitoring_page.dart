import 'dart:async';
import 'dart:convert';
import 'package:abtms/widgets/my_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class UpdatedMonitoringPage extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothConnection connection;
  final VoidCallback onDisconnect;

  UpdatedMonitoringPage({
    required this.device,
    required this.connection,
    required this.onDisconnect,
  });

  @override
  State<UpdatedMonitoringPage> createState() => _UpdatedMonitoringPageState();
}

class _UpdatedMonitoringPageState extends State<UpdatedMonitoringPage> {
  BluetoothConnection? _connection;

  String heartrate = "0";
  String temp = "0";
  String spo2 = "0";
  bool isMeasuring = false;

  String getHeartRateStatus(String heartrate) {
    int hr = int.parse(heartrate);
    if (hr < 60) {
      return 'Low';
    } else if (hr > 100) {
      return 'High';
    } else {
      return 'Normal';
    }
  }

  Color getHeartRateColor(String heartrate) {
    int hr = int.parse(heartrate);
    if (hr < 60) {
      return Colors.red;
    } else if (hr > 100) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String getSpo2Status(String spo2) {
    int sp = int.parse(spo2);
    if (sp < 95) {
      return 'Low';
    } else {
      return 'Normal';
    }
  }

  Color getSpo2Color(String spo2) {
    int sp = int.parse(spo2);
    if (sp < 95) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  String getTempStatus(String temp) {
    double temperature = double.parse(temp);
    if (temperature < 36.0) {
      return 'Low';
    } else if (temperature > 37.5) {
      return 'High';
    } else {
      return 'Normal';
    }
  }

  Color getTempColor(String temp) {
    double temperature = double.parse(temp);
    if (temperature < 36.0) {
      return Colors.blue;
    } else if (temperature > 37.5) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    widget.connection.input?.listen((data) {
      String incomingMessage = ascii.decode(data);
      print('Data incoming: $incomingMessage');
      _parseIncomingData(incomingMessage);
    })?.onDone(() {
      print('Disconnected by remote request');
      _handleDisconnect();
    });
  }

  String _buffer = '';

  void _parseIncomingData(String data) {
    _buffer += data; // Add incoming data to the buffer

    if (_buffer.contains('\n')) {
      List<String> measurements = _buffer.split('\n');

      // Process all complete lines of data
      for (int i = 0; i < measurements.length - 1; i++) {
        _processMeasurement(measurements[i].trim());
      }

      // Keep the last (possibly incomplete) part in the buffer
      _buffer = measurements.last;
    }
  }

  void _processMeasurement(String measurement) {
    Map<String, String> updates = {};

    if (measurement.contains('BPM:')) {
      String value = measurement.split(':')[1].trim();
      updates['heartrate'] = value == '-999' ? '0' : value;
    } else if (measurement.contains('SPO2:')) {
      String value = measurement.split(':')[1].trim();
      updates['spo2'] = value == '-999' ? '0' : value;
    } else if (measurement.contains('Temp:')) {
      String value = measurement.split(':')[1].trim();
      if (value == '-127.00') {
        updates['temp'] = '0';
      } else {
        double temperatureValue = double.parse(value);
        updates['temp'] = temperatureValue.toInt().toString();
      }
    }

    if (updates.isNotEmpty) {
      setState(() {
        heartrate = updates['heartrate'] ?? heartrate;
        spo2 = updates['spo2'] ?? spo2;
        temp = updates['temp'] ?? temp;
      });
    }

    if (measurement.contains('Measurement complete')) {
      setState(() {
        isMeasuring = false;
      });
      _saveMeasurementToDatabase();
    }
  }

  void _saveMeasurementToDatabase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(user.uid)
            .collection('measurements')
            .add({
          'heartrate': heartrate,
          'spo2': spo2,
          'temperature': temp,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Measurement saved to database');
      } else {
        print('User not authenticated');
      }
    } catch (e) {
      print('Error saving measurement to database: $e');
    }
  }

  void _handleDisconnect() {
    widget.onDisconnect(); // Call the callback to update the parent state
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device disconnected')),
      );
    }
  }

  void _sendMessage(String message) async {
    try {
      widget.connection.output.add(utf8.encode(message + "\r\n"));
      await widget.connection.output.allSent;
      print('Message sent: $message');
      if (message == 'measure') {
        setState(() {
          isMeasuring = true;
          heartrate = "0";
          spo2 = "0";
          temp = "0";
        });
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  void _disconnect() async {
    try {
      await widget.connection.close();
      print('Disconnected');
      _handleDisconnect();
    } catch (e) {
      print('Error disconnecting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to disconnect: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        _disconnect();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFf2f3f5),
        appBar: const UpdatedMonitoringAppBar(),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: double.infinity,
                height: screenHeight * 0.27,
                padding: EdgeInsets.all(screenHeight * 0.004),
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
                    image: const DecorationImage(
                      image: AssetImage(
                        "assets/images/blood oxygen bg.png",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: CircularPercentIndicator(
                          radius: screenHeight * 0.1,
                          percent: spo2 == '0' ? 0 : int.parse(spo2) / 100.0,
                          lineWidth: 7,
                          progressColor:
                              spo2 == '0' ? Colors.red : Colors.white,
                          backgroundColor: Colors.transparent,
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  spo2,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.068,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                "%spo2",
                                style: TextStyle(
                                  fontSize: screenHeight * 0.025,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Image.asset(
                            "assets/images/logo/blood oxidation.png",
                            height: screenHeight * 0.05,
                          ),
                          Text(
                            "%spO2",
                            style: TextStyle(
                              fontSize: screenHeight * 0.025,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: screenWidth * 0.435,
                    height: screenHeight * 0.25,
                    padding: EdgeInsets.all(screenHeight * 0.004),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[300],
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white,
                        image: const DecorationImage(
                          image: AssetImage(
                            "assets/images/heart rate bg.png",
                          ),
                          fit: BoxFit.cover,
                        ),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline
                                .alphabetic, // Required for baseline alignment
                            children: [
                              Text(
                                heartrate == '0' ? '0' : heartrate,
                                style: TextStyle(
                                  fontSize: screenHeight * 0.06,
                                  color: heartrate == '0'
                                      ? Colors.red
                                      : Colors.black,
                                  textBaseline: TextBaseline.alphabetic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.003,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                "Heart Rate",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "(bpm)",
                                style: TextStyle(
                                  fontSize: screenHeight *
                                      0.02, // Adjust this based on desired size
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  textBaseline: TextBaseline
                                      .alphabetic, // Align to the same baseline
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.435,
                    height: screenHeight * 0.25,
                    padding: EdgeInsets.all(screenHeight * 0.004),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[300],
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF2C93E7),
                            Color(0xFF195281),
                          ],
                        ),
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
                          Text(
                            temp,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenHeight * 0.06,
                              color: Colors.white,
                              textBaseline: TextBaseline.alphabetic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                "Temperature",
                                style: TextStyle(
                                  color: Color(0xFF91CEFF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "°C",
                                style: TextStyle(
                                  fontSize: screenHeight *
                                      0.025, // Adjust this based on desired size
                                  color: const Color(0xFF91CEFF),
                                  textBaseline: TextBaseline
                                      .alphabetic, // Align to the same baseline
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenHeight * 0.004),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: screenHeight * 0.02,
                    vertical: screenHeight * 0.01,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Heart Rate = ",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            heartrate == '0'
                                ? 'No readings Recorded'
                                : getHeartRateStatus(heartrate),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: heartrate == '0'
                                  ? Colors.grey[600]
                                  : getHeartRateColor(heartrate),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Blood Oxidation = ",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            spo2 == '0'
                                ? 'No Readings Recorded'
                                : getSpo2Status(spo2),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: spo2 == '0'
                                  ? Colors.grey[600]
                                  : getSpo2Color(spo2),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Temperature = ",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            temp == '0'
                                ? 'No Readings Recorded'
                                : getTempStatus(temp),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: temp == '0'
                                  ? Colors.grey[600]
                                  : getTempColor(temp),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.065,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          isMeasuring ? null : () => _sendMessage("measure"),
                      child: Text(isMeasuring ? "Measuring..." : "Measure"),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.065,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _disconnect,
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
