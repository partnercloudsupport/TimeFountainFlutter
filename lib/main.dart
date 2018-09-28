import 'package:flutter/material.dart';
import 'screens/control.dart';
import 'screens/deviceList.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'TimeFountain',
    home: DeviceListScreen(),
    );
  }
}
