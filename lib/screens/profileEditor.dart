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

  ProfileDTO getProfile() {
    return timeFountainDTO.profiles.elementAt(profileIndex);
  }

  void _addColorConfiguration() {
    _communicator.send('add colorconfiguration', (String configuration) {
      List<String> args = configuration.split(' ');
      if (args.length != 6) {
        return "Invalid amount of arguments ${args.length}";
      }
      int color = int.tryParse(args[0], radix: 16);
      ColorBehaviour behaviour =
          args[1] == 'linear' ? ColorBehaviour.linear : ColorBehaviour.sine;
      double frequencyDelta = double.tryParse(args[2]);
      double offset = double.tryParse(args[3]);
      double amplitude = double.tryParse(args[4]);
      int flashDuration = int.tryParse(args[5]);
      if (color == null ||
          frequencyDelta == null ||
          offset == null ||
          amplitude == null ||
          flashDuration == null) {
        return "Failed to parse colorconfiguration from response";
      }
    });
    setState(() {
      getProfile().colorConfigurationDTO.add(ColorConfigurationDTO(
          Color.fromARGB(255, 0, 255, 0),
          0.0,
          0.0,
          1.0,
          ColorBehaviour.linear,
          1500));
    });
  }

  void _deleteColorConfiguration(index) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Editor')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
          onPressed: _addColorConfiguration, child: Icon(Icons.add)),
    );
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
                builder: (context) => ColorEditorScreen(_communicator, colorConfiguration, index));
            setState(() {});
          },
          trailing: _buildItemMenu(index),
        );
      },
    );
  }

  Widget _buildItemMenu(index) {
    return PopupMenuButton(
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem>[
          PopupMenuItem(
            value: 'delete',
            child: new ListTile(
              title: Text('Delete'),
            ),
          )
        ];
      },
      onSelected: (value) {
        if (value == 'delete') {
          _deleteColorConfiguration(index);
        }
      },
    );
  }
}
