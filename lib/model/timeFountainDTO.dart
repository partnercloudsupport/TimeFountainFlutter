import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import './profileDTO.dart';
import './colorConfigurationDTO.dart';

class TimeFountainDTO {
  TimeFountainDTO();

  void _addDefaultProfile()
  {
    profiles.add(ProfileDTO());
    profiles.elementAt(profiles.length - 1).colorConfigurationDTO.add(ColorConfigurationDTO(Color.fromARGB(255, 255, 255, 255), 0.0, 0.0, 0.0, ColorBehaviour.linear, 1500));
  }

  void load(SharedPreferences preferences) {
    int numProfiles = preferences.getInt('numprofiles') ?? 0;
    profiles = [];
    _addDefaultProfile();

    for (int i = 1; i < numProfiles + 1; ++i) {
      profiles.add(ProfileDTO());
      profiles[i].load(preferences, i - 1);
    }
  }

  void save(SharedPreferences preferences) {
    preferences.setInt('numprofiles', profiles.length - 1);

    for (int i = 1; i < profiles.length; ++i)
    {
      profiles[i].save(preferences, i - 1);
    }
  }

  bool powerState = false;
  bool calibrating = false;
  int motorDuty = 0;
  ProfileDTO activeProfile;
  List<ProfileDTO> profiles = [];
}
