enum ColorBehaviour {
  linear,
  sine
}

class ColorConfigurationDTO {
  ColorConfigurationDTO(this.red, this.green, this.blue,
  this.frequencyDelta, this.offset, this.amplitude, this.behaviour, this.flashDuration);

  double frequencyDelta;
	double offset;
	double amplitude;
	int flashDuration;
	ColorBehaviour behaviour;
	int red;
	int green;
	int blue;
}
