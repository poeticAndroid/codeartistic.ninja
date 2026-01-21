extends Area2D

signal absorbed

var ink_color = HSL.new()
var ink_fill = 8

var staying

var _pulse = 0
var _one = Vector2.ZERO

var in_puddle = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2.ZERO
	await get_tree().create_timer(1).timeout
	if not staying: queue_free()
	if ink_fill <= 0: queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _one.x < 1:
		_one += Vector2(0.015625, 0.015625)
	_pulse += 2.4 * delta
	scale = _one * (sqrt(ink_fill / PI) * 0.75)
	scale.x += sin(_pulse) * 0.01
	scale.y += cos(_pulse) * 0.01


func set_ink_color(h = ink_color.hue, s = ink_color.saturation, l = ink_color.lightness):
	ink_color.hue = h
	ink_color.saturation = s
	ink_color.lightness = l
	modulate = Color.from_ok_hsl(ink_color.hue, ink_color.saturation, ink_color.lightness)


func set_ink_fill(p):
	ink_fill = p


func to_obj():
	var obj = {
			type = "obj", obj = "Puddle", id = name,
			x = position.x, y = position.y,
			ink_fill = ink_fill,
			h = ink_color.hue,
			s = ink_color.saturation,
			l = ink_color.lightness,
		}
	if ink_fill <= 0:
		queue_free()
	return obj


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("puddle") and area.ink_fill:
		if ink_fill <= area.ink_fill and ink_fill:
			in_puddle = area
			in_puddle.ink_color.blend(in_puddle.ink_color, ink_color,
					ink_fill / (ink_fill + in_puddle.ink_fill))
			ink_color.copy_from(in_puddle.ink_color)
			in_puddle.set_ink_color()
			set_ink_color()

			in_puddle.set_ink_fill(ink_fill + in_puddle.ink_fill)
			set_ink_fill(0)
			emit_signal("absorbed", self)


func _on_area_exited(area: Area2D) -> void:
	if area == in_puddle:
		in_puddle = null
