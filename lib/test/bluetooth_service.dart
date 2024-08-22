import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothManager {
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;

  // Callback for disconnection
  Function()? onDisconnected;

  Future<bool> enableBluetooth() async {
    bool isEnabled = await _bluetooth.isEnabled ?? false;
    if (!isEnabled) {
      await _bluetooth.requestEnable();
    }
    return await _bluetooth.isEnabled ?? false;
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    return await _bluetooth.getBondedDevices();
  }

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
    await Future.delayed(Duration(seconds: 15)); // Discovery for 20 seconds
    await _bluetooth.cancelDiscovery();
    return results;
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      print('Attempting to connect to ${device.name}');
      _connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device ${device.name}');
      _connectedDevice = device;

      // Set up listener for disconnection
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

      // Perform any necessary initialization here
      await _initializeConnection();

      return true;
    } catch (exception) {
      print('Cannot connect to ${device.name}, exception occurred: $exception');
      return false;
    }
  }

  Future<void> _initializeConnection() async {
    // Send any necessary initialization commands to your device
    // For example:
    // await _connection!.output.add(Uint8List.fromList(utf8.encode("INIT\r\n")));
    // await _connection!.output.allSent;
  }

  void _handleDisconnection() {
    _connection?.dispose();
    _connection = null;
    _connectedDevice = null;
    if (onDisconnected != null) {
      onDisconnected!();
    }
  }

  void disconnect() {
    _handleDisconnection();
  }

  Future<void> sendMessage(String message) async {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(message.codeUnits));
      await _connection!.output.allSent;
    } else {
      print('Not connected to any device');
    }
  }

  Stream<Uint8List>? listenForData() {
    return _connection?.input;
  }

  BluetoothDevice? get connectedDevice => _connectedDevice;

  void retryConnection(BluetoothDevice device) {
    Future.delayed(Duration(seconds: 5), () {
      if (_connection == null) {
        connectToDevice(device);
      }
    });
  }
}
