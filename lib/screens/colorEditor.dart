import 'package:flutter/material.dart';
import '../model/colorConfigurationDTO.dart';

class ColorEditorScreen extends StatefulWidget {
  final ColorConfigurationDTO colorConfigurationDTO;
  ColorEditorScreen(this.colorConfigurationDTO);
  @override
  ColorState createState() => new ColorState(colorConfigurationDTO);
}

class ColorState extends State<ColorEditorScreen> {
  ColorConfigurationDTO colorConfiguration;
  ColorConfigurationDTO colorConfigurationCopy;
  ColorState(this.colorConfiguration)
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
              onTap: () { },
              child: Row(children: <Widget>[
                Expanded(
                    child: Container(
                  height: 32.0,
                  color: colorConfigurationCopy.color
                ))
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
            colorConfiguration.amplitude = colorConfigurationCopy.amplitude;
            colorConfiguration.offset = colorConfigurationCopy.offset;
            colorConfiguration.frequencyDelta =
                colorConfigurationCopy.frequencyDelta;
            colorConfiguration.flashDuration =
                colorConfigurationCopy.flashDuration;
            colorConfiguration.behaviour = colorConfigurationCopy.behaviour;
            colorConfiguration.color = colorConfigurationCopy.color;
            Navigator.of(context).pop();
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
