import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../model/timeFountainDTO.dart';
import './profileEditor.dart';

class ControlScreen extends StatefulWidget {
  final BluetoothDevice device;
  ControlScreen(this.device);

  @override
  ControlState createState() => new ControlState(this.device);
}

class ControlState extends State<ControlScreen> {
  final TextStyle _titleFont =
      TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold);
  final TextStyle _biggerFont = TextStyle(fontSize: 16.0);
  final TextStyle _boldFont = TextStyle(fontWeight: FontWeight.bold);

  final BluetoothDevice device;
  final TimeFountainDTO timeFountainDTO = new TimeFountainDTO();

  ControlState(this.device);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title:
                Text(device.name.length > 0 ? device.name : 'Unnamed Device')),
        body: _buildBody());
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        _buildTopRow(),
        _buildProfileList(),
      ],
    );
  }

  Widget _buildTopRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(device.name.length > 0 ? device.name : 'Unnamed Device',
                style: _titleFont),
          ),
          Text('Power', style: _biggerFont),
          Switch(
            onChanged: _sendPowerState,
            value: timeFountainDTO.powerState,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList() {
    return Expanded(
        child: ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        if (index >= timeFountainDTO.profiles.length && index >= 2) {
          return null;
        }
        return ListTile(
          title: Text('Profile ${index + 1}', style: index == timeFountainDTO.activeProfile ? _boldFont : TextStyle()),
          onTap: () {
            _editProfile(context, index);
          },
          onLongPress: () {
            _makeProfileActive(index);
          },
        );
      },
    ));
  }

  void _sendPowerState(bool state) {
    setState(() {
      timeFountainDTO.powerState = state;
    });
  }

  void _editProfile(BuildContext context, int index) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditorScreen(device, timeFountainDTO, index)));
  }

  void _makeProfileActive(int index) {
    setState(() {
      timeFountainDTO.activeProfile = index;
    });
  }
}
