import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../model/timeFountainDTO.dart';

class ProfileEditorScreen extends StatefulWidget {
  final BluetoothDevice device;
  final TimeFountainDTO timeFountainDTO;
  final int index;

ProfileEditorScreen(this.device, this.timeFountainDTO, this.index);

  @override
  ProfileState createState() => new ProfileState(device, timeFountainDTO, index);
}

class ProfileState extends State<ProfileEditorScreen> {
  final BluetoothDevice device;
  final TimeFountainDTO timeFountainDTO;
  final int index;

  ProfileState(this.device, this.timeFountainDTO, this.index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Profile Editor')),);
  }
}