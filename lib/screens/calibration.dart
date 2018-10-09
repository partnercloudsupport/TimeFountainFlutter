import 'package:flutter/material.dart';
import '../bluetooth/bluetoothCommunicator.dart';

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

  CalibrationState(this._communicator);

  @override
  void initState() {
    super.initState();
    _communicator.send('set calibration on', (_) {
      _communicator.send('get motorduty', (strMotorDuty) {
        int duty = int.tryParse(strMotorDuty);
        if (duty == null) {
          return;
        }
        _communicator.send('get basefrequency', (strBaseFrequency) {
          double frequency = double.tryParse(strBaseFrequency);
          if (frequency == null) {
            return;
          }

          setState(() {
            _motorDuty = duty;
            _baseFrequency = frequency;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _communicator.send('set calibration off', (_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Calibration")), body: _buildBody());
  }

  Widget _buildBody() {
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
                  _motorDuty = (value * 1023.0).round();
                });
              },
              onChangeEnd: (value) {
                int duty = (value * 1023.0).round();
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
                        _communicator.send(
                            'set basefrequency $frequency', (_) {});
                        _baseFrequency = frequency;
                      }
                    },
                  )
                ])),
      ],
    );
  }
}
