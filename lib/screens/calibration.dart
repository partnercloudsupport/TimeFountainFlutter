import 'package:flutter/material.dart';
import '../bluetooth/bluetoothCommunicator.dart';
import '../model/profileDTO.dart';
import '../model/colorConfigurationDTO.dart';

class CalibrationScreen extends StatefulWidget {
  final BluetoothCommunicator _communicator;
  CalibrationScreen(this._communicator);
  @override
  CalibrationState createState() => new CalibrationState(_communicator);
}

class CalibrationState extends State<CalibrationScreen> {
  final BluetoothCommunicator _communicator;
  int _motorDuty = 0;
  double _baseFrequency = 50.0;

  bool _loading;

  CalibrationState(this._communicator) : _loading = true;

  @override
  void initState() {
    super.initState();

    ProfileDTO profile = new ProfileDTO();
    profile.colorConfigurationDTO.add(new ColorConfigurationDTO(
        Color(0xFFFFFFFF), 0.0, 0.0, 0.0, ColorBehaviour.linear, 1500));
    _communicator.send('set profile $profile', (_) {
      _communicator.send('get motorduty', (strMotorDuty) {
        int duty = int.tryParse(strMotorDuty);
        if (duty == null) {
          return;
        }
        _communicator.send('get frequency', (strBaseFrequency) {
          double frequency = double.tryParse(strBaseFrequency);
          if (frequency == null) {
            return;
          }

          setState(() {
            _motorDuty = duty;
            _baseFrequency = frequency;
            _loading = false;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Calibration")), body: _buildBody());
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Motorduty',
                  style: TextStyle(fontSize: 18.0),
                )),
            Slider(
              value: _motorDuty / 1023.0,
              onChanged: (value) {
                setState(() {
                  _motorDuty = (value * 1023).round();
                });
              },
              onChangeEnd: (value) {
                int duty = (value * 1023).round();
                _communicator.send('set motorduty $duty', (_) {
                  setState(() {
                    _motorDuty = duty;
                  });
                });
              },
            )
          ],
        ),
        Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Base frequency',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  TextField(
                    controller: TextEditingController.fromValue(
                        TextEditingValue(text: _baseFrequency.toString())),
                    onChanged: (value) {
                      double frequency = double.tryParse(value);
                      if (frequency != null) {
                        _communicator.send('set frequency $frequency', (_) {});
                        _baseFrequency = frequency;
                      }
                    },
                  )
                ])),
      ],
    );
  }
}
