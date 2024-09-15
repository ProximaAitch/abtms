import 'package:abtms/widgets/my_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Alerts"),
      body: Center(
        child: Text("No alerts"),
      ),
    );
  }
}
