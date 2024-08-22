import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'bluetooth_service.dart';
import 'connected_device.dart';

class DeviceListScreen extends StatefulWidget {
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  BluetoothManager _manager = BluetoothManager();
  List<BluetoothDiscoveryResult> _devices = [];
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _enableBluetooth();
  }

  void _enableBluetooth() async {
    bool isEnabled = await _manager.enableBluetooth();
    if (isEnabled) {
      _getPairedDevices();
    }
  }

  void _getPairedDevices() async {
    List<BluetoothDevice> pairedDevices = await _manager.getPairedDevices();
    setState(() {
      _devices = pairedDevices
          .map((device) => BluetoothDiscoveryResult(
                device: device,
                rssi: 0,
              ))
          .toList();
    });
  }

  void _startDiscovery() async {
    setState(() {
      _isDiscovering = true;
    });

    List<BluetoothDiscoveryResult> results = await _manager.startDiscovery();

    setState(() {
      _devices = results;
      _isDiscovering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bluetooth Devices',
          style: TextStyle(fontSize: 17),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(CupertinoIcons.back),
        ),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          BluetoothDiscoveryResult result = _devices[index];
          return ListTile(
            title: Text(result.device.name ?? "Unknown device"),
            subtitle: Text(result.device.address),
            trailing: Text(result.rssi.toString()),
            onTap: () async {
              bool connected = await _manager.connectToDevice(result.device);
              if (connected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Connected to ${result.device.name}'),
                  ),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BluetoothDeviceManager(server: result.device),
                  ),
                );
                setState(
                    () {}); // Refresh to update the connected device indicator
              }
            },
            tileColor:
                _manager.connectedDevice?.address == result.device.address
                    ? Colors.lightBlueAccent
                    : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: _isDiscovering ? null : _startDiscovery,
        child: _isDiscovering
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.search),
        tooltip: 'Scan for devices',
      ),
    );
  }
}
