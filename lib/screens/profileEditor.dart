import 'package:flutter/material.dart';
import '../model/timeFountainDTO.dart';
import '../model/colorConfigurationDTO.dart';
import '../model/profileDTO.dart';
import './colorEditor.dart';
import '../bluetooth/bluetoothCommunicator.dart';
import '../widgets/outlinedRaindrop.dart';

class ProfileEditorScreen extends StatefulWidget {
  final BluetoothCommunicator _communicator;
  final TimeFountainDTO _timeFountainDTO;
  final int _profileIndex;

  ProfileEditorScreen(this._communicator, this._timeFountainDTO, this._profileIndex);

  @override
  ProfileState createState() =>
      new ProfileState();
}

class ProfileState extends State<ProfileEditorScreen> {

  ProfileState();

  ProfileDTO getProfile() {
    return widget._timeFountainDTO.profiles.elementAt(widget._profileIndex);
  }

  @override
  void initState()
  {
    super.initState();
    _update();
  }

  void _update() {
    widget._communicator.send('set profile ${getProfile()}', (String response) {});
  }

  void _addColorConfiguration() {
    setState(() {
      getProfile().colorConfigurationDTO.add(ColorConfigurationDTO(
          Color(0xFFFFFFFF), 0.0, 0.0, 0.0, ColorBehaviour.linear, 1500));
      _update();
    });
  }

  void _deleteColorConfiguration(int index) {
    setState(() {
      getProfile().colorConfigurationDTO.removeAt(index);
      _update();
    });
  }

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
                child: OutlinedRaindrop(colorConfiguration.color),
              ),
              Text(
                'Color ${index + 1}',
              ),
            ],
          ),
          onTap: () async {
            await showDialog(
                context: context,
                builder: (context) => ColorEditorScreen(colorConfiguration));
            setState(() {
              _update();
            });
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
