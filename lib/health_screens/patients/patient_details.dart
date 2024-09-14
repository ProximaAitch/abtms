import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PatientDetailsPage extends StatelessWidget {
  const PatientDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient Details',
          style: TextStyle(fontSize: 17),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
