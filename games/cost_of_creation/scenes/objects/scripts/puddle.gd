extends Area2D

var ink_color = HSL.new()
var ink_fill = 8

var staying

var _pulse = 0
var _one = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2.ZERO
	await get_tree().create_timer(1).timeout
	if not staying: queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _one.x < 1:
		_one += Vector2(0.01, 0.01)
	_pulse += 2.4 * delta
	scale = _one * (ink_fill / 8)
	scale.x += sin(_pulse) * 0.01
	scale.y += cos(_pulse) * 0.01


func set_ink_color(h, s, l):
	ink_color.hue = h
	ink_color.saturation = s
	ink_color.lightness = l
	modulate = Color.from_ok_hsl(ink_color.hue, ink_color.saturation, ink_color.lightness)


func set_ink_fill(p):
	ink_fill = p
	if ink_fill < 0.1:
		queue_free()


func to_obj():
	var obj = {
			type = "obj", obj = "Puddle", id = name,
			x = position.x, y = position.y,
			ink_fill = ink_fill,
			h = ink_color.hue,
			s = ink_color.saturation,
			l = ink_color.lightness,
		}
	return obj
