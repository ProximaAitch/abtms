import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothManager {
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;

  // Callback for disconnection
  Function()? onDisconnected;

  // Check if Bluetooth is enabled and request the user to turn it on if not.
  Future<void> checkAndRequestBluetooth(BuildContext context) async {
    bool isEnabled = await _bluetooth.isEnabled ?? false;
    if (!isEnabled) {
      _showBluetoothSettingsDialog(context);
    }
  }

  // Show a dialog to direct the user to Bluetooth settings.
  void _showBluetoothSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth is off'),
          content: const Text('Please turn on Bluetooth in your device settings to continue.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Go to Settings'),
              onPressed: () {
                _openBluetoothSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Open the Bluetooth settings on the device.
  void _openBluetoothSettings() async {
    if (await Permission.bluetooth.request().isGranted) {
      _bluetooth.openSettings();
    } else {
      print('Bluetooth permission not granted');
    }
  }

  // Get a list of paired devices.
  Future<List<BluetoothDevice>> getPairedDevices() async {
    return await _bluetooth.getBondedDevices();
  }

  // Start discovery of Bluetooth devices and return the list of found devices.
  Future<List<BluetoothDiscoveryResult>> startDiscovery() async {
    List<BluetoothDiscoveryResult> results = [];
    _bluetooth.startDiscovery().listen((r) {
      final existingIndex = results.indexWhere((element) => element.device.address == r.device.address);
      if (existingIndex >= 0) {
        results[existingIndex] = r;
      } else {
        results.add(r);
      }
    });
    await Future.delayed(Duration(seconds: 15)); // Discovery duration
    await _bluetooth.cancelDiscovery();
    return results;
  }

  // Connect to a selected Bluetooth device.
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      print('Attempting to connect to ${device.name}');
      _connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device ${device.name}');
      _connectedDevice = device;

      // Set up listener for disconnection and incoming data
      _connection!.input!.listen(
        (Uint8List data) {
          print('Data received: ${String.fromCharCodes(data)}');
        },
        onDone: () {
          print('Disconnected by remote request from ${device.name}');
          _handleDisconnection();
          retryConnection(device);
        },
        onError: (error) {
          print('Error receiving data: $error');
        },
      );

      // Perform any necessary initialization
      await _initializeConnection();

      return true;
    } catch (exception) {
      print('Cannot connect to ${device.name}, exception occurred: $exception');
      return false;
    }
  }

  // Initialize the connection (if needed, send initial commands).
  Future<void> _initializeConnection() async {
    // Send any necessary initialization commands to your device
    // For example:
    // await _connection!.output.add(Uint8List.fromList(utf8.encode("INIT\r\n")));
    // await _connection!.output.allSent;
  }

  // Handle disconnection of the Bluetooth device.
  void _handleDisconnection() {
    _connection?.dispose();
    _connection = null;
    _connectedDevice = null;
    if (onDisconnected != null) {
      onDisconnected!();
    }
  }

  // Manually disconnect from the current Bluetooth device.
  void disconnect() {
    _handleDisconnection();
  }

  // Send a message to the connected Bluetooth device.
  Future<void> sendMessage(String message) async {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(message.codeUnits));
      await _connection!.output.allSent;
    } else {
      print('Not connected to any device');
    }
  }

  // Listen for incoming data from the connected Bluetooth device.
  Stream<Uint8List>? listenForData() {
    return _connection?.input;
  }

  // Get the currently connected Bluetooth device.
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Retry connecting to a Bluetooth device after a delay if disconnected.
  void retryConnection(BluetoothDevice device) {
    Future.delayed(const Duration(seconds: 5), () {
      if (_connection == null) {
        connectToDevice(device);
      }
    });
  }

  enableBluetooth() {}
}
