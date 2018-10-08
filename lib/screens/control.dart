import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../model/timeFountainDTO.dart';
import '../model/profileDTO.dart';
import './profileEditor.dart';
import '../bluetooth/bluetoothCommunicator.dart';
import '../bluetooth/errorCode.dart';

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

  final TimeFountainDTO _timeFountainDTO = new TimeFountainDTO();
  final String _deviceName;
  BluetoothCommunicator _communicator;
  bool _loading;
  bool _disposed;

  ControlState(BluetoothDevice device)
      : _deviceName = device.name.length > 0 ? device.name : 'Unnamed Device',
        _loading = true,
        _disposed = false {
    _communicator = new BluetoothCommunicator(device, _onError);
    _communicator.connect(_onConnected);
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    _communicator.disconnect();
  }

  void _onConnected() {
    _communicator.send('get version', (String version) {
      if (version != 'TimeFountain v1.0') {
        _onError(ErrorCode.error_invalid_version, version);
        return;
      }

      _communicator.send('get numprofiles', (String strNumProfiles) {
        int numProfiles = int.tryParse(strNumProfiles);
        if (numProfiles == null) {
          _onError(
              ErrorCode.error_response, "Num Profiles could not be parsed");
          return;
        }
        int i = 0;
        Function onProfileResponse;
        onProfileResponse = (String profileResponse) {
          _timeFountainDTO.profiles.add(_getProfileFromString(profileResponse));
          ++i;
          if (i < numProfiles) {
            _communicator.send('get profile $i', onProfileResponse);
          } else {
            setState(() {
              _loading = false;
            });
          }
        };
        _communicator.send('get profile $i', onProfileResponse);
      });
    });
  }

  void _onError(ErrorCode status, String message,
      [bool popStack = true]) async {
    if (context == null) {
      return;
    }
    Map<ErrorCode, String> statusMessages = new Map();

    statusMessages[ErrorCode.error_disconnected] = "Disconnected from Device";
    statusMessages[ErrorCode.error_characteristic_not_found] =
        "Read/Write Characteristic not found";
    statusMessages[ErrorCode.error_not_connected] = "Not connected to Device";
    statusMessages[ErrorCode.error_send] = "Failed to send message";
    statusMessages[ErrorCode.error_timeout] = "Connection timed out";
    statusMessages[ErrorCode.error_no_handler_available] =
        "No handler was available to handle the response";
    statusMessages[ErrorCode.error_response] = "Error in response";
    statusMessages[ErrorCode.error_invalid_version] =
        "Invalid version of Device";

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(statusMessages[status] +
                (message != null ? ':\n' + message : '')),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
    if (!_disposed && popStack) {
      Navigator.of(context).pop();
    }
  }

  void _sendPowerState(bool state) {
    _communicator.send('set power ${state ? 'on' : 'off'}', (String data) {
      setState(() {
        _timeFountainDTO.powerState = data == '1';
      });
    });
  }

  void _addProfile() {
    _communicator.send('add profile', (String strIdx) {
      int idx = int.tryParse(strIdx);
      if (idx == null) {
        _onError(ErrorCode.error_response, "Failed to parse profileIdx");
      }
      _communicator.send('get profile $idx', (String strProfile) {
        setState(() {
          _timeFountainDTO.profiles.add(_getProfileFromString(strProfile));
        });
      });
    }, false);
  }

  void _editProfile(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfileEditorScreen(_communicator, _timeFountainDTO, index)));
  }

  void _deleteProfile(int index) {
    showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              title: Text('Warning'),
              content: Text(
                  'Profile $index will be irrevocably deleted. Are you sure you want to continue?'),
              actions: <Widget>[
                FlatButton(
                    child: Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      _communicator.send('remove profile $index', (_) {
                        setState(() {
                          _timeFountainDTO.profiles.removeAt(index);
                        });
                      }, false);
                      Navigator.of(context).pop();
                    }),
              ],
            ));
  }

  void _makeProfileActive(int index) {
    _communicator.send('set activeprofile $index', (response) {
      int activeProfile = int.tryParse(response);
      if (activeProfile == null || activeProfile != index)
      {
        _onError(ErrorCode.error_response, "Failed to parse activeprofile. Was $activeProfile expected $index");
        return;
      }
      setState(() {
        _timeFountainDTO.activeProfile = activeProfile;
      });
    });
  }

  ProfileDTO _getProfileFromString(String str) {
    return ProfileDTO();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_deviceName), actions: <Widget>[_buildMenu()],),
      body: _buildBody(),
      floatingActionButton: _loading
          ? null
          : FloatingActionButton(
              onPressed: _addProfile, child: Icon(Icons.add)),
              
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
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
            child: Text(_deviceName, style: _titleFont),
          ),
          Text('Power', style: _biggerFont),
          Switch(
            onChanged: _sendPowerState,
            value: _timeFountainDTO.powerState,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList() {
    return Expanded(
        child: ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _timeFountainDTO.profiles.length * 2,
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        if (index >= _timeFountainDTO.profiles.length) {
          return null;
        }
        return ListTile(
          title: Text(index == 0 ? 'Default Profile' : 'Profile $index',
              style: index == _timeFountainDTO.activeProfile
                  ? _boldFont
                  : TextStyle()),
          trailing: index != 0 ? _buildItemMenu(index) : null,
          onTap: () {
            _makeProfileActive(index);
          },
        );
      },
    ));
  }

  Widget _buildItemMenu(index) {
    return PopupMenuButton(
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem>[
          PopupMenuItem(
            value: 'edit',
            child: new ListTile(
              title: Text('Edit'),
            ),
          ),
          index != 0
              ? PopupMenuItem(
                  value: 'delete',
                  child: new ListTile(
                    title: Text('Delete'),
                  ),
                )
              : null
        ];
      },
      onSelected: (value) {
        if (value == 'edit') {
          _editProfile(index);
        } else if (value == 'delete') {
          _deleteProfile(index);
        }
      },
    );
  }

Widget _buildMenu() {
  return PopupMenuButton(
    itemBuilder: (BuildContext context) {
      return <PopupMenuItem>[
        PopupMenuItem(
          value: 'calibrate',
          child: new ListTile(title: Text('Calibrate'))
        ),
        PopupMenuItem(
          value: 'disconnect',
          child: new ListTile(title: Text('Disconnect'))
        )
      ];
    },
    onSelected: (value) {
      if (value == 'calibrate')
      {

      }
      else if (value == 'disconnect')
      {
        Navigator.of(context).pop();
      }
    },
  );
}

}
