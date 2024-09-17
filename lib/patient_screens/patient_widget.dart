// import 'package:abtms/patient_screens/new_patient_ui.dart';
// import 'package:abtms/patient_screens/history.dart';
// import 'package:abtms/patient_screens/initial_screen.dart';
// import 'package:abtms/patient_screens/monitoring.dart';
// import 'package:abtms/patient_screens/settings.dart';
// import 'package:abtms/patient_screens/tips/health_tips_screen.dart';
// import 'package:abtms/utils/bluetooth_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class PatientWidget extends StatefulWidget {
//   PatientWidget({super.key});

//   @override
//   State<PatientWidget> createState() => _PatientWidgetState();
// }

// class _PatientWidgetState extends State<PatientWidget> {
//   int index = 0;
//   final BluetoothManager _bluetoothManager = BluetoothManager();
//   bool _isConnected = false;
//   BluetoothDevice? _connectedDevice;
//   bool _isScanning = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkBluetoothConnection();
//   }

//   Future<void> _checkBluetoothConnection() async {
//     await _bluetoothManager.checkAndRequestBluetooth(context);
//     if (_bluetoothManager.connectedDevice != null) {
//       setState(() {
//         _isConnected = true;
//         _connectedDevice = _bluetoothManager.connectedDevice;
//       });
//     } else {
//       setState(() {
//         _isConnected = false;
//         _connectedDevice = null;
//       });
//     }
//   }

//   void _updateConnectionStatus(bool isConnected, {BluetoothDevice? device}) {
//     setState(() {
//       _isConnected = isConnected;
//       _connectedDevice = device;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final connectedScreens = _connectedDevice != null
//         // ? [
//         //     PatientMonitoringPage(
//         //         server: _connectedDevice!), // When Bluetooth is connected
//         //     const PatientHistoryPage(),
//         //     HealthTipsPage(),
//         //     const PatientSettingsPage(),
//         //   ]
//         // ? [
//         //     UpdatedMonitoringPage(), // When Bluetooth is connected
//         //     const PatientHistoryPage(),
//         //     HealthTipsPage(),
//         //     const PatientSettingsPage(),
//         //   ]
//         // : [
//         //     UpdatedMonitoringPage(), // When Bluetooth is not connected
//         //     const PatientHistoryPage(),
//         //     HealthTipsPage(),
//         //     const PatientSettingsPage(),
//         //   ];

//     return Scaffold(
//       bottomNavigationBar: NavigationBarTheme(
//         data: const NavigationBarThemeData(
//           surfaceTintColor: Colors.transparent,
//           indicatorColor: Color(0xFFD4DBFF),
//           backgroundColor: Color(0xFFF3F3F4),
//           labelTextStyle: MaterialStatePropertyAll(
//             TextStyle(
//               color: Colors.black,
//               fontSize: 13.5,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         child: NavigationBar(
//           selectedIndex: index,
//           onDestinationSelected: (index) => setState(() => this.index = index),
//           destinations: const [
//             NavigationDestination(
//               icon: FaIcon(FontAwesomeIcons.heartPulse),
//               label: "Monitoring",
//               selectedIcon: FaIcon(
//                 FontAwesomeIcons.heartPulse,
//                 color: Color(0xFF3E4D99),
//               ),
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.history),
//               label: "History",
//               selectedIcon: Icon(
//                 Icons.history,
//                 color: Color(0xFF3E4D99),
//               ),
//             ),
//             NavigationDestination(
//               icon: Icon(CupertinoIcons.heart_circle),
//               label: "Health Tips",
//               selectedIcon: Icon(
//                 CupertinoIcons.heart_circle_fill,
//                 color: Color(0xFF3E4D99),
//               ),
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.settings_outlined),
//               label: "Settings",
//               selectedIcon: Icon(
//                 Icons.settings,
//                 color: Color(0xFF3E4D99),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: connectedScreens[index],
      
//     );
//   }

//   void _startDiscovery() async {
//     setState(() {
//       _isScanning = true;
//     });

//     List<BluetoothDiscoveryResult> results =
//         await _bluetoothManager.startDiscovery();
//     bool deviceFound = false;
//     for (var result in results) {
//       if (result.device.name == 'ABTMS-Bluetooth') {
//         deviceFound = true;
//         _showConnectDialog(result.device);
//         break;
//       }
//     }

//     if (!deviceFound) {
//       setState(() {
//         _isScanning = false;
//       });
//       _showDeviceNotFoundDialog();
//     }
//   }

//   void _showConnectDialog(BluetoothDevice device) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Connect to ${device.name}'),
//         content: Text('Do you want to connect to this device?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               bool connected = await _bluetoothManager.connectToDevice(device);
//               if (connected) {
//                 _updateConnectionStatus(true, device: device);
//               } else {
//                 // Show an error message
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                       content: Text('Failed to connect to ${device.name}')),
//                 );
//               }
//               setState(() {
//                 _isScanning = false;
//               });
//             },
//             child: Text('Connect'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeviceNotFoundDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Device Not Found'),
//         content: Text('Could not find ABTMS-Bluetooth device.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
// }
