import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import './profileDTO.dart';
import './colorConfigurationDTO.dart';

class TimeFountainDTO {
  TimeFountainDTO();

  void load(SharedPreferences preferences) {
    int numProfiles = preferences.getInt('numprofiles') ?? 0;
    profiles = [];

    for (int i = 0; i < numProfiles; ++i) {
      profiles.add(ProfileDTO());
      profiles[i].load(preferences, i);
    }
  }

  void save(SharedPreferences preferences) {
    preferences.setInt('numprofiles', profiles.length);

    for (int i = 0; i < profiles.length; ++i)
    {
      profiles[i].save(preferences, i);
    }
  }

  bool powerState = false;
  bool calibrating = false;
  int motorDuty = 0;
  ProfileDTO activeProfile;
  List<ProfileDTO> profiles = [];
}
