import 'package:abtms/patient_screens/history.dart';
import 'package:abtms/patient_screens/updated_monitoring_page.dart';
import 'package:abtms/patient_screens/settings.dart';
import 'package:abtms/patient_screens/tips/health_tips_screen.dart';
import 'package:abtms/patient_screens/utils/bluetooth_aware.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MainPatientWrapper extends StatefulWidget {
  MainPatientWrapper({Key? key}) : super(key: key);

  @override
  State<MainPatientWrapper> createState() => _MainPatientWrapperState();
}

class _MainPatientWrapperState extends State<MainPatientWrapper> {
  int index = 0;
  late BluetoothAwareMonitoringPage bluetoothPage;
  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    bluetoothPage = BluetoothAwareMonitoringPage(
      onConnectionChanged: _handleBluetoothConnectionChange,
    );
    screens = [
      bluetoothPage,
      HealthTipsPage(),
      MyHealthHistoryPage(),
      PatientSettingsPage(),
    ];
  }

  void _handleBluetoothConnectionChange(bool isConnected) {
    // Here you can handle Bluetooth connection changes if needed
    print("Bluetooth connection changed: $isConnected");
    setState(() {}); // Trigger a rebuild to update the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        currentIndex: index,
        onTap: (index) => setState(() => this.index = index),
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.heartPulse),
            label: "Monitoring",
            activeIcon: FaIcon(FontAwesomeIcons.heartPulse),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart_circle),
            label: "Health Tips",
            activeIcon: Icon(CupertinoIcons.heart_circle_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
            activeIcon: Icon(Icons.history),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
            activeIcon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
