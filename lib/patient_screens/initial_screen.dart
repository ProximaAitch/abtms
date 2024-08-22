import 'package:abtms/controllers/controllers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PatientMonitoringAppbar(),
      body: Center(
        child: Text("Bluetooth device not connected"),
      ),
    );
  }
}
