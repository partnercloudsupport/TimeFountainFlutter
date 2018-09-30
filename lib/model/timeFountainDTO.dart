import './profileDTO.dart';

class TimeFountainDTO {
  TimeFountainDTO();

  bool powerState = false;
  bool calibrating = false;
  int motorDuty = 0;
  int activeProfile = 0;
  List<ProfileDTO> profiles = [];
}
