import 'package:abtms/health_screens/alerts.dart';
import 'package:abtms/health_screens/patients_page.dart';
import 'package:abtms/health_screens/settings.dart';
import 'package:flutter/material.dart';

class HealthWidget extends StatefulWidget {
  HealthWidget({super.key});

  @override
  State<HealthWidget> createState() => _HealthWidgetState();
}

class _HealthWidgetState extends State<HealthWidget> {
  int index = 0;
  final screens = [
    PatientsPage(),
    const AlertsPage(),
    const HealthSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
          surfaceTintColor: Colors.transparent,
          indicatorColor: Color(0xFFD4DBFF),
          backgroundColor: Color(0xFFF3F3F4),
          labelTextStyle: MaterialStatePropertyAll(
            TextStyle(
              // color: Color(0xFF3E4D99),
              color: Colors.black,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() => this.index = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.people_alt_outlined,
              ),
              label: "Patients",
              selectedIcon: Icon(
                Icons.people_alt_rounded,
                color: Color(0xFF3E4D99),
              ),
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications),
              label: "Alerts",
              selectedIcon: Icon(
                Icons.notifications_active,
                color: Color(0xFF3E4D99),
              ),
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: "Settings",
              selectedIcon: Icon(
                Icons.settings,
                color: Color(0xFF3E4D99),
              ),
            ),
          ],
        ),
      ),
      body: screens[index],
    );
  }
}
