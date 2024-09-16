import 'package:abtms/patient_screens/history.dart';
import 'package:abtms/patient_screens/new_patient_ui.dart';
import 'package:abtms/patient_screens/settings.dart';
import 'package:abtms/patient_screens/tips/health_tips_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainPatientWrapper extends StatefulWidget {
  MainPatientWrapper({super.key});

  @override
  State<MainPatientWrapper> createState() => _MainPatientWrapperState();
}

class _MainPatientWrapperState extends State<MainPatientWrapper> {
  int index = 0;

  final screens = [
    UpdatedMonitoringPage(),
    HealthTipsPage(),
    PatientHistoryPage(),
    PatientSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[500],
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        currentIndex: index,
        onTap: (index) => setState(() => this.index = index),
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.heartPulse),
            label: "Monitoring",
            activeIcon: FaIcon(
              FontAwesomeIcons.heartPulse,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart_circle),
            label: "Health Tips",
            activeIcon: Icon(
              CupertinoIcons.heart_circle_fill,
            ),
            // color: Color(0xFF3E4D99),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
            ),
            label: "History",
            activeIcon: Icon(
              Icons.history,
              // color: Color(0xFF3E4D99),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_outlined,
            ),
            label: "Settings",
            activeIcon: Icon(
              Icons.settings,
              // color: Color(0xFF3E4D99),
            ),
          ),
        ],
      ),
    );
  }
}
