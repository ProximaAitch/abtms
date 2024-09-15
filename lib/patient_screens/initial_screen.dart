import 'package:abtms/widgets/my_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UpdatedMonitoringAppBar(),
      body: Center(
        child: Column(
          children: [
            Text("Bluetooth device not connected"),
            ElevatedButton(
              onPressed: () {},
              child: Text("Turn On Bluetooth"),
            ),
          ],
        ),
      ),
    );
  }
}
