import 'package:flutter/material.dart';

enum ColorBehaviour { linear, sine }

class ColorConfigurationDTO {
  ColorConfigurationDTO(this.color, this.frequencyDelta, this.offset,
      this.amplitude, this.behaviour, this.flashDuration);

  double frequencyDelta;
  double offset;
  double amplitude;
  int flashDuration;
  ColorBehaviour behaviour;
  Color color;
}
