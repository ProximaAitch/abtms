import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  final int rssi;
  final VoidCallback onTap;

  const BluetoothDeviceTile({Key? key, required this.device, required this.rssi, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.name.isNotEmpty ? device.name : 'Unknown device'),
      subtitle: Text(device.id.id),
      trailing: Text(rssi.toString()),
      onTap: onTap,
    );
  }
}