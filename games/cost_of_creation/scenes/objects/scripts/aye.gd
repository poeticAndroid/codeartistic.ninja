extends Area2D

signal pressed

var target = Vector2.ZERO
var paused = true

var ink_color = HSL.new()
var ink_fill = 0.25

var in_puddle = null
var spill = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_ink_color(ink_color.hue, ink_color.saturation, ink_color.lightness)
	set_ink_fill(ink_fill)
	modulate.a = 0
	get_tree().create_tween().tween_property(self, "modulate:a", 1, 2)
	if Global.persistant.has("creation_aye"):
		set_ink_fill(Global.persistant.creation_aye.ink_fill)
		set_ink_color(
				Global.persistant.creation_aye.h,
				Global.persistant.creation_aye.s,
				Global.persistant.creation_aye.l
			)
	if OS.is_debug_build():
		set_ink_fill(0.5)
		set_ink_color(0.5, 0.5, 0.75)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target and not paused:
		animate("walk")
		var dir = target - position
		if dir.length() > 96 * delta:
			dir = dir.normalized() * 96 * delta
		else:
			paused = true
		position += dir
	else:
		animate("idle")

	if in_puddle and paused:
		in_puddle.ink_color.blend(in_puddle.ink_color, ink_color,
				ink_fill / (ink_fill + in_puddle.ink_fill))
		ink_color.copy_from(in_puddle.ink_color)
		in_puddle.set_ink_color()
		set_ink_color()

		if spill:
			if ink_fill > 0:
				in_puddle.set_ink_fill(in_puddle.ink_fill + 0.12 * delta)
				set_ink_fill(ink_fill - 0.12 * delta)
			elif ink_fill < 0:
				in_puddle.set_ink_fill(in_puddle.ink_fill + ink_fill)
				set_ink_fill(0)
		else:
			if ink_fill < 1 and in_puddle.ink_fill > 0:
				in_puddle.set_ink_fill(in_puddle.ink_fill - 0.12 * delta)
				set_ink_fill(ink_fill + 0.12 * delta)
			elif ink_fill > 1:
				in_puddle.set_ink_fill(in_puddle.ink_fill + ink_fill - 1)
				set_ink_fill(1)
			elif in_puddle.ink_fill < 0:
				set_ink_fill(in_puddle.ink_fill + ink_fill)
				in_puddle.set_ink_fill(0)


func animate(anim):
	%StrokeSprite.play(anim)
	%FillSprite.play(anim)
	if target:
		if position.x > target.x:
			%StrokeSprite.flip_h = true
			%FillSprite.flip_h = true
		if position.x < target.x:
			%StrokeSprite.flip_h = false
			%FillSprite.flip_h = false


func set_ink_color(h = ink_color.hue, s = ink_color.saturation, l = ink_color.lightness):
	ink_color.hue = h
	ink_color.saturation = s
	ink_color.lightness = l
	%InkMask.modulate = Color.from_ok_hsl(ink_color.hue, ink_color.saturation, ink_color.lightness)


func set_ink_fill(p):
	ink_fill = p
	%InkMask.position.y = 128 * (1 - ink_fill)


func set_username(name):
	$SuckBtn.tooltip_text = name


func goto(pos):
	paused = false
	spill = false
	target = pos


func stop():
	paused = true


func leave():
	await get_tree().create_tween().tween_property(self, "modulate:a", 0, 60).finished
	queue_free()


func to_obj():
	var obj = {
			type = "obj", obj = "Aye", id = "from",
			x = target.x, y = target.y,
			spill = spill,
			ink_fill = ink_fill,
			h = ink_color.hue,
			s = ink_color.saturation,
			l = ink_color.lightness,
		}
	Global.persistant.creation_aye = obj
	return obj


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("puddle"):
		in_puddle = area


func _on_area_exited(area: Area2D) -> void:
	if area == in_puddle: in_puddle = null


func _on_suck_btn_pressed() -> void:
	emit_signal("pressed")
