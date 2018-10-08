import 'package:flutter/material.dart';
import '../model/timeFountainDTO.dart';
import '../model/colorConfigurationDTO.dart';
import '../model/profileDTO.dart';
import './colorEditor.dart';
import '../bluetooth/bluetoothCommunicator.dart';

class ProfileEditorScreen extends StatefulWidget {
  final BluetoothCommunicator _communicator;
  final TimeFountainDTO _timeFountainDTO;
  final int index;

  ProfileEditorScreen(this._communicator, this._timeFountainDTO, this.index);

  @override
  ProfileState createState() =>
      new ProfileState(_communicator, _timeFountainDTO, index);
}

class ProfileState extends State<ProfileEditorScreen> {
  final BluetoothCommunicator _communicator;
  final TimeFountainDTO timeFountainDTO;
  final int profileIndex;

  ProfileState(this._communicator, this.timeFountainDTO, this.profileIndex);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Editor')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
          onPressed: _addColorConfiguration, child: Icon(Icons.add)),
    );
  }

  ProfileDTO getProfile() {
    return timeFountainDTO.profiles.elementAt(profileIndex);
  }

  Widget _buildBody() {
    return ListView.builder(
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();
        int index = i ~/ 2;
        if (index >= getProfile().colorConfigurationDTO.length) {
          return null;
        }

        ColorConfigurationDTO colorConfiguration =
            getProfile().colorConfigurationDTO.elementAt(index);

        return ListTile(
            title: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        left: 16.0, top: 8.0, bottom: 8.0, right: 16.0),
                    child: Image(
                        height: 42.0,
                        image: AssetImage('assets/raindrop.png'),
                        color: colorConfiguration.color)),
                Text(
                  'Color ${index + 1}',
                ),
              ],
            ),
            onTap: () async {
              await showDialog(
                  context: context,
                  builder: (context) => ColorEditorScreen(colorConfiguration));
              setState(() {});
            });
      },
    );
  }

  void _addColorConfiguration() {
    setState(() {
      timeFountainDTO.profiles
          .elementAt(profileIndex)
          .colorConfigurationDTO
          .add(ColorConfigurationDTO(Color.fromARGB(255, 0, 255, 0), 0.0, 0.0,
              1.0, ColorBehaviour.linear, 1500));
    });
  }
}
