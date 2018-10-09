import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import './control.dart';

FlutterBlue flutterBlue = FlutterBlue.instance;

class DeviceListScreen extends StatefulWidget {
  @override
  DeviceListState createState() => new DeviceListState();
}

class DeviceListState extends State<DeviceListScreen>
    with WidgetsBindingObserver {
  final _devices = <BluetoothDevice>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _smallerFont = const TextStyle(fontSize: 12.0);
  var _scanSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device List'),
      ),
      body: _buildDeviceList(),
    );
  }

  Widget _buildDeviceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;

        if (index >= _devices.length) {
          return null;
        }
        return _buildRow(context, _devices[index]);
      },
    );
  }

  Widget _buildRow(BuildContext context, BluetoothDevice device) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            device.name.length > 0 ? device.name : 'Unnamed Device',
            style: _biggerFont,
          ),
          Text(
            device.id.id,
            style: _smallerFont,
          ),
        ],
      ),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ControlScreen(device)));
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startListening();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.suspending ||
        state == AppLifecycleState.inactive) {
      _stopListening();
    }
  }

  void _scanListener(ScanResult scanResult) {
    if (!_devices.any((device) {
      return device.id.id == scanResult.device.id.id;
    })) {
      setState(() {
        _devices.add(scanResult.device);
      });
    }
  }

  void _startListening() {
    if (_scanSubscription == null) {
      _scanSubscription = flutterBlue.scan().listen(_scanListener);
    }
  }

  void _stopListening() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }
}
