import 'package:flutter/material.dart';
import '../model/colorConfigurationDTO.dart';
import './colorPicker.dart';
import '../bluetooth/bluetoothCommunicator.dart';

class ColorEditorScreen extends StatefulWidget {
  final ColorConfigurationDTO colorConfigurationDTO;
  final BluetoothCommunicator _communicator;
  int index;
  ColorEditorScreen(this._communicator, this.colorConfigurationDTO, this.index);
  @override
  ColorState createState() =>
      new ColorState(_communicator, colorConfigurationDTO, this.index);
}

class ColorState extends State<ColorEditorScreen> {
  ColorConfigurationDTO colorConfiguration;
  ColorConfigurationDTO colorConfigurationCopy;
  final BluetoothCommunicator _communicator;
  int index;
  ColorState(this._communicator, this.colorConfiguration, this.index)
      : colorConfigurationCopy = new ColorConfigurationDTO(
            colorConfiguration.color,
            colorConfiguration.frequencyDelta,
            colorConfiguration.offset,
            colorConfiguration.amplitude,
            colorConfiguration.behaviour,
            colorConfiguration.flashDuration);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
              onTap: () {
                _showColorPicker(context, colorConfigurationCopy);
              },
              child: Row(children: <Widget>[
                Expanded(
                    child: Container(
                        height: 32.0, color: colorConfigurationCopy.color))
              ])),
          _buildInputField(
              'ΔFrequency',
              (String value) => _setFrequency(colorConfigurationCopy, value),
              colorConfigurationCopy.frequencyDelta.toString()),
          _buildInputField(
              'Offset',
              (String value) => _setOffset(colorConfigurationCopy, value),
              colorConfigurationCopy.offset.toString()),
          _buildInputField(
              'Amplitude',
              (String value) => _setAmplitude(colorConfigurationCopy, value),
              colorConfigurationCopy.amplitude.toString()),
          _buildInputField(
              'FlashDuration',
              (String value) =>
                  _setFlashDuration(colorConfigurationCopy, value),
              colorConfigurationCopy.flashDuration.toString()),
          _buildBehaviourDropdown(colorConfigurationCopy)
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            _communicator.send(
                'set colorconfiguration $index ' +
                    '--color=${colorConfigurationCopy.color.value.toRadixString(16)} ' +
                    '--amplitude=${colorConfigurationCopy.amplitude} ' +
                    '--offset=${colorConfigurationCopy.offset} ' +
                    '--frequencydelta=${colorConfigurationCopy.frequencyDelta} ' +
                    '--flashduration=${colorConfigurationCopy.flashDuration} ' +
                    '--behaviour=${colorConfigurationCopy.behaviour == ColorBehaviour.linear ? 'linear' : 'sine'}',
                (_) {
              colorConfiguration.amplitude = colorConfigurationCopy.amplitude;
              colorConfiguration.offset = colorConfigurationCopy.offset;
              colorConfiguration.frequencyDelta =
                  colorConfigurationCopy.frequencyDelta;
              colorConfiguration.flashDuration =
                  colorConfigurationCopy.flashDuration;
              colorConfiguration.behaviour = colorConfigurationCopy.behaviour;
              colorConfiguration.color = colorConfigurationCopy.color;
              Navigator.of(context).pop();
            });
          },
        )
      ],
    );
  }

  void _setFrequency(ColorConfigurationDTO colorConfiguration, String value) {
    double val = double.tryParse(value);
    if (val != null) {
      colorConfiguration.frequencyDelta = val;
    }
  }

  void _setOffset(ColorConfigurationDTO colorConfiguration, String value) {
    double val = double.tryParse(value);
    if (val != null) {
      colorConfiguration.offset = val;
    }
  }

  void _setAmplitude(ColorConfigurationDTO colorConfiguration, String value) {
    double val = double.tryParse(value);
    if (val != null) {
      colorConfiguration.amplitude = val;
    }
  }

  void _setFlashDuration(
      ColorConfigurationDTO colorConfiguration, String value) {
    int val = int.tryParse(value);
    if (val != null) {
      colorConfiguration.flashDuration = val;
    }
  }

  void _showColorPicker(
      BuildContext context, ColorConfigurationDTO colorConfiguration) async {
    await showDialog(
        context: context,
        builder: (context) => new ColorPickerScreen(colorConfiguration));
    setState(() {});
  }

  Widget _buildInputField(String hint, onChanged, String initialValue) {
    return Padding(
        padding: EdgeInsets.only(left: 16.0, top: 12.0, bottom: 12.0),
        child: TextField(
          decoration: InputDecoration(hintText: hint),
          onChanged: onChanged,
          controller: TextEditingController(text: initialValue),
        ));
  }

  Widget _buildBehaviourDropdown(ColorConfigurationDTO colorConfiguration) {
    return DropdownButton<ColorBehaviour>(
        items: [
          DropdownMenuItem(value: ColorBehaviour.linear, child: Text('Linear')),
          DropdownMenuItem(value: ColorBehaviour.sine, child: Text('Sine'))
        ],
        onChanged: (ColorBehaviour value) {
          setState(() {
            colorConfiguration.behaviour = value;
          });
        },
        hint: Text('Behaviour'),
        value: colorConfiguration.behaviour);
  }
}
