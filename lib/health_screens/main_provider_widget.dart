import 'package:abtms/health_screens/alerts.dart';
import 'package:abtms/health_screens/patients_page.dart';
import 'package:abtms/health_screens/settings.dart';
import 'package:flutter/material.dart';

class HealthProviderWrapper extends StatefulWidget {
  HealthProviderWrapper({super.key});

  @override
  State<HealthProviderWrapper> createState() => _HealthProviderWrapperState();
}

class _HealthProviderWrapperState extends State<HealthProviderWrapper> {
  int index = 0;

  final screens = [
    PatientsPage(),
    const AlertsPage(),
    const HealthSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[500],
        currentIndex: index,
        onTap: (index) => setState(() => this.index = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.people_alt_outlined,
            ),
            label: "Patients",
            activeIcon: Icon(
              Icons.people_alt,
              // color: Color(0xFF3E4D99),
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications,
            ),
            label: "Alerts",
            activeIcon: Icon(
              Icons.notifications_active,
              // color: Color(0xFF3E4D99),
            ),
          ),
          const BottomNavigationBarItem(
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
