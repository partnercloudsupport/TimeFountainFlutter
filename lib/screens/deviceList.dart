import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

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
  var scanSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        return _buildRow(_devices[index]);
      },
    );
  }

  Widget _buildRow(BluetoothDevice device) {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              device.name.length > 0 ? device.name : 'Unknown Device',
              style: _biggerFont,
            ),
            Text(
              device.id.id,
              style: _smallerFont,
            ),
          ],
        ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      scanSubscription = flutterBlue.scan().listen(_scanListener);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.suspending ||
        state == AppLifecycleState.inactive) {
      if (scanSubscription != null) {
        scanSubscription.cancel();
      }
      scanSubscription = null;
    }
  }

  void _scanListener(ScanResult scanResult) {
    if (!_devices.any((device) {
      return device.id.id == scanResult.device.id.id;
    })) {
      _devices.add(scanResult.device);
    }
  }
}
