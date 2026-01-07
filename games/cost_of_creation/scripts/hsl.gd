class_name HSL


func _init(_hue = 0.0, _saturation = 0.0, _lightness = 0.0):
	self.set_to(_hue, _saturation, _lightness)


func set_to(_hue = self._hue, _saturation = self._saturation, _lightness = self._lightness):
	self.hue = _hue
	self.saturation = _saturation
	self.lightness = _lightness
	return self.normalize()


func copyFrom(a: HSL):
	return self.set_to(a.hue, a.saturation, a.lightness)


func copyTo(a: HSL):
	return a.set_to(self.hue, self.saturation, self.lightness)


func blend(a: HSL, b: HSL = self, bias = 0.5, result = self):
	var hueDiff = b.hue - a.hue
	var satDiff = b.saturation - a.saturation
	var litDiff = b.lightness - a.lightness

	while hueDiff < -0.5: hueDiff += 1.0
	while hueDiff > +0.5: hueDiff -= 1.0

	if a.saturation < b.saturation:
		a.hue = a.hue + (satDiff / b.saturation) * hueDiff
		hueDiff = b.hue - a.hue

	if b.saturation < a.saturation:
		b.hue = b.hue + (satDiff / a.saturation) * hueDiff
		hueDiff = b.hue - a.hue

	while hueDiff < -0.5: hueDiff += 1.0
	while hueDiff > +0.5: hueDiff -= 1.0

	result.hue = a.hue + bias * hueDiff
	result.saturation = max(a.saturation, b.saturation)
	result.lightness = a.lightness + bias * litDiff

	return result.normalize()


func normalize(result = self):
	result.hue = self.hue
	while result.hue < 0.0: result.hue += 1.0
	while result.hue > 1.0: result.hue -= 1.0

	result.saturation = min(max(0.0, self.saturation), 1.0)
	result.lightness = min(max(0.0, self.lightness), 1.0)
	if abs(result.lightness - round(result.lightness)) < 0.1:
		result.saturation = 0.0

	return result
