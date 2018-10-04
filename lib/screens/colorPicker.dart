import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../model/colorConfigurationDTO.dart';

class ColorPickerScreen extends StatefulWidget {
  final ColorConfigurationDTO colorConfiguration;

  ColorPickerScreen(this.colorConfiguration);

  @override
  ColorPickerState createState() => new ColorPickerState(colorConfiguration);
}

class ColorPickerState extends State<ColorPickerScreen> {
  final ColorConfigurationDTO colorConfiguration;
  ColorConfigurationDTO colorConfigurationCopy;

  ColorPickerState(this.colorConfiguration)
      : colorConfigurationCopy = new ColorConfigurationDTO(
            colorConfiguration.color,
            colorConfiguration.frequencyDelta,
            colorConfiguration.offset,
            colorConfiguration.amplitude,
            colorConfiguration.behaviour,
            colorConfiguration.flashDuration);

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: const Text('Choose a color'),
      content: new SingleChildScrollView(
        child: new ColorPicker(
          pickerColor: colorConfigurationCopy.color,
          onColorChanged: (Color value) => setState(() {
                colorConfigurationCopy.color = value;
              }),
          enableLabel: true,
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        new FlatButton(
          child: new Text('OK'),
          onPressed: () {
            setState(() {
              colorConfiguration.color = colorConfigurationCopy.color;
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
