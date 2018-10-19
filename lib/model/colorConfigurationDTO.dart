import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ColorBehaviour { linear, sine }

class ColorConfigurationDTO {
  ColorConfigurationDTO(this.color, this.frequencyDelta, this.offset,
      this.amplitude, this.behaviour, this.flashDuration);

  void load(SharedPreferences preferences, int profileIndex, int colorConfigurationIndex)
  {
    frequencyDelta = preferences.getDouble('frequencyDelta $profileIndex $colorConfigurationIndex') ?? 0.0;
    offset = preferences.getDouble('offset $profileIndex $colorConfigurationIndex') ?? 0.0;
    amplitude = preferences.getDouble('amplitude $profileIndex $colorConfigurationIndex') ?? 0.0;
    flashDuration = preferences.getInt('flashDuration $profileIndex $colorConfigurationIndex') ?? 1500;
    behaviour = (preferences.getString('behaviour $profileIndex $colorConfigurationIndex') ?? 'linear') == 'linear' ? ColorBehaviour.linear : ColorBehaviour.sine;
    color = Color(preferences.getInt('color $profileIndex $colorConfigurationIndex') ?? 0xFFFFFFFF);
  }

  void save(SharedPreferences preferences, int profileIndex, int colorConfigurationIndex)
  {
    preferences.setDouble('frequencyDelta $profileIndex $colorConfigurationIndex', frequencyDelta);
    preferences.setDouble('offset $profileIndex $colorConfigurationIndex', offset);
    preferences.setDouble('amplitude $profileIndex $colorConfigurationIndex', amplitude);
    preferences.setInt('flashDuration $profileIndex $colorConfigurationIndex', flashDuration);
    preferences.setString('behaviour $profileIndex $colorConfigurationIndex', (behaviour == ColorBehaviour.linear) ? 'linear' : 'sine');
    preferences.setInt('color $profileIndex $colorConfigurationIndex', color.value);
  }

  @override
  String toString()
  {
    return "${(color.value & 0xFFFFFF).toRadixString(16)} ${behaviour == ColorBehaviour.linear ? 'linear' : 'sine'} $frequencyDelta $offset $amplitude $flashDuration";
  }

  double frequencyDelta;
  double offset;
  double amplitude;
  int flashDuration;
  ColorBehaviour behaviour;
  Color color;
}
