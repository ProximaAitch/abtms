import 'dart:async';
import 'package:abtms/patient_screens/updated_monitoring_page.dart';
import 'package:abtms/widgets/my_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothAwareMonitoringPage extends StatefulWidget {
  final Function(bool) onConnectionChanged;

  BluetoothAwareMonitoringPage({Key? key, required this.onConnectionChanged})
      : super(key: key);

  @override
  _BluetoothAwareMonitoringPageState createState() =>
      _BluetoothAwareMonitoringPageState();
}

class _BluetoothAwareMonitoringPageState
    extends State<BluetoothAwareMonitoringPage>
    with AutomaticKeepAliveClientMixin<BluetoothAwareMonitoringPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothDevice? _connectedDevice;
  List<BluetoothDevice> _devicesList = [];
  bool _isLoading = true;
  bool _isConnecting = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  BluetoothConnection? connection;
  BluetoothConnection? _connection;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _requestPermissions() async {
  if (await Permission.bluetooth.isDenied) {
    await Permission.bluetooth.request();
  }
  if (await Permission.bluetoothScan.isDenied) {
    await Permission.bluetoothScan.request();
  }
  if (await Permission.bluetoothConnect.isDenied) {
    await Permission.bluetoothConnect.request();
  }
}

  Future<void> _initializeBluetooth() async {
    await _getBleState();
    _listenForBluetoothStateChanges();
  }

  Future<void> _getBleState() async {
    setState(() => _isLoading = true);
    try {
      _bluetoothState = await FlutterBluetoothSerial.instance.state;
      print("Current Bluetooth state: $_bluetoothState");
      if (_bluetoothState.isEnabled) {
        await _getPairedDevices();
      }
    } catch (e) {
      print("Error getting Bluetooth state: $e");
      if (_retryCount < _maxRetries) {
        _retryCount++;
        await Future.delayed(Duration(seconds: 1));
        return _getBleState();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _listenForBluetoothStateChanges() {
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      print("Bluetooth state changed to: $state");
      setState(() {
        _bluetoothState = state;
        if (state.isEnabled) {
          _getPairedDevices();
        } else {
          _connectedDevice = null;
          _devicesList = [];
        }
      });
    });
  }

  Future<void> _getPairedDevices() async {
    try {
      List<BluetoothDevice> devices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      print("Paired devices: ${devices.length}");
      setState(() => _devicesList = devices);
    } catch (e) {
      print("Error getting paired devices: $e");
    }
  }

  void _showBluetoothOffDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bluetooth is Off'),
          content: Text('Please turn on Bluetooth to use this feature.'),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Turn On', style: TextStyle(color: Colors.blue[600])),
              onPressed: () async {
                await FlutterBluetoothSerial.instance.openSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeviceSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a device'),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_devicesList[index].name ?? "Unknown device"),
                  subtitle: Text(_devicesList[index].address),
                  onTap: () {
                    _connectToDevice(_devicesList[index]);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
    });

    try {
      connection = await BluetoothConnection.toAddress(device.address)
          .timeout(Duration(seconds: 60));

      setState(() {
        _connectedDevice = device;
        _isConnecting = false;
      });

      widget.onConnectionChanged(true);

      // Instead of navigating, we'll update the state to show the UpdatedMonitoringPage
      setState(() {});

    } catch (e) {
      print('Error connecting to device: $e');
      setState(() {
        _isConnecting = false;
      });
      widget.onConnectionChanged(false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to connect: $e'),
      ));
    }
  }


  void _handleDisconnect() {
    setState(() {
      _connectedDevice = null;
      _connection = null;
    });
    _checkBluetoothState();
  }

  void _checkBluetoothState() async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    setState(() {});
  }


 @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_bluetoothState.isEnabled) {
      return BluetoothOffScreen(
          showBluetoothOffDialog: _showBluetoothOffDialog);
    }

    if (_connectedDevice == null) {
      return DeviceNotConnected(
        onConnectPressed: _showDeviceSelectionDialog,
        isPaired: _devicesList.isNotEmpty,
        isConnecting: _isConnecting,
      );
    }

    return UpdatedMonitoringPage(
      device: _connectedDevice!,
      connection: connection!,
      onDisconnect: _handleDisconnect,
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  final VoidCallback showBluetoothOffDialog;

  const BluetoothOffScreen({Key? key, required this.showBluetoothOffDialog})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf2f3f5),
      appBar: UpdatedMonitoringAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bluetooth_disabled,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 20),
              Text(
                'Bluetooth is Disabled',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Please enable Bluetooth to use this feature',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.bluetooth),
                label: Text('Turn On Bluetooth'),
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: showBluetoothOffDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceNotConnected extends StatelessWidget {
  final VoidCallback onConnectPressed;
  final bool isPaired;
  final bool isConnecting;

  const DeviceNotConnected({
    Key? key,
    required this.onConnectPressed,
    required this.isPaired,
    required this.isConnecting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf2f3f5),
      appBar: UpdatedMonitoringAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPaired ? Icons.bluetooth_searching : Icons.bluetooth,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                isPaired ? 'Device not connected' : 'No paired devices found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                isPaired
                    ? 'Tap on the connect button to connect to device'
                    : 'Pair a device in your Bluetooth settings',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(isPaired ? Icons.bluetooth_connected : Icons.add),
                label: Text(isPaired ? "Connect" : "Pair a device"),
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: onConnectPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
