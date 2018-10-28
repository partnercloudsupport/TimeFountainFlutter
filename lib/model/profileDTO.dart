import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './colorConfigurationDTO.dart';

class ProfileDTO {
  ProfileDTO();

  void load(SharedPreferences preferences, int profileIndex)
  {
    int numColorConfigurations = preferences.getInt('numcolorconfigurations $profileIndex');

    for (int i = 0; i < numColorConfigurations; ++i)
    {
      ColorConfigurationDTO conf = ColorConfigurationDTO(Color(0xFFFFFFFF), 0.0, 0.0, 0.0, ColorBehaviour.linear, 1500);
      conf.load(preferences, profileIndex, i);
      colorConfigurationDTO.add(conf);
    }
  }

  void save(SharedPreferences preferences, int profileIndex)
  {
    preferences.setInt('numcolorconfigurations $profileIndex', colorConfigurationDTO.length);

    for (int i = 0; i < colorConfigurationDTO.length; ++i)
    {
      colorConfigurationDTO[i].save(preferences, profileIndex, i);
    }
  }

  @override
  String toString()
  {
    String str = "${colorConfigurationDTO.length}";
    for (int i = 0; i < colorConfigurationDTO.length; ++i)
    {
      str += " ${colorConfigurationDTO[i]}";
    }
    return str;
  }

  List<ColorConfigurationDTO> colorConfigurationDTO = [];
}
