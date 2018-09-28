import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ControlScreen extends StatelessWidget {
  final BluetoothDevice device;
  ControlScreen(this.device);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Control')));
  } 

}
