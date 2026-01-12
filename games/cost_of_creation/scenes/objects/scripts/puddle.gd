extends Area2D

var ink_color = HSL.new()
var ink_fill = 8

var _pulse = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_pulse += 2.4 * delta
	scale = Vector2.ONE * (ink_fill / 8)
	scale.x += sin(_pulse) * 0.01
	scale.y += cos(_pulse) * 0.01


func set_ink_color(h, s, l):
	ink_color.hue = h
	ink_color.saturation = s
	ink_color.lightness = l
	modulate = Color.from_ok_hsl(ink_color.hue, ink_color.saturation, ink_color.lightness)


func set_ink_fill(p):
	ink_fill = p
