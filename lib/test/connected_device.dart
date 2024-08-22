import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

class BluetoothDeviceManager extends StatefulWidget {
  final BluetoothDevice server;

  const BluetoothDeviceManager({Key? key, required this.server})
      : super(key: key);

  @override
  _BluetoothDeviceManagerState createState() => _BluetoothDeviceManagerState();
}

class _BluetoothDeviceManagerState extends State<BluetoothDeviceManager> {
  BluetoothConnection? connection;
  String bpm = "";
  String spo2 = "";
  Timer? keepAliveTimer;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  void _connectToDevice() async {
    try {
      connection = await BluetoothConnection.toAddress(widget.server.address);
      print('Connected to the device');
      listenForData();
      startKeepAlive();
    } catch (e) {
      print('Error connecting to device: $e');
      retryConnection();
    }
  }

  void sendMessage(String message) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(utf8.encode(message + "\n")));
      connection!.output.allSent.then((_) {
        print('Message sent: $message');
      }).catchError((error) {
        print('Error sending message: $error');
      });
    } else {
      print('Not connected to any device');
    }
  }

  void listenForData() {
    connection!.input!.listen((Uint8List data) {
      String receivedData = utf8.decode(data);
      print('Received data: $receivedData');

      setState(() {
        if (receivedData.contains("BPM:")) {
          bpm = receivedData.split("BPM:")[1].trim();
        } else if (receivedData.contains("SPO2:")) {
          spo2 = receivedData.split("SPO2:")[1].trim();
        }
      });
    }).onDone(() {
      print('Disconnected by remote request');
      setState(() {
        connection = null;
      });
      retryConnection();
    });
  }

  void startKeepAlive() {
    keepAliveTimer = Timer.periodic(Duration(seconds: 30), (_) {
      sendMessage('keep-alive');
    });
  }

  void retryConnection() {
    Future.delayed(Duration(seconds: 7), () {
      if (connection == null) {
        _connectToDevice();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bluetooth Device Manager')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('BPM: $bpm'),
            Text('SPO2: $spo2'),
            ElevatedButton(
              onPressed: () => sendMessage('measure'),
              child: Text('Measure'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    keepAliveTimer?.cancel();
    connection?.dispose();
    super.dispose();
  }
}
