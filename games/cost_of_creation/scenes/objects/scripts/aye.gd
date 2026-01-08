extends Area2D

var target = Vector2.ZERO
var paused = true

var ink_color = HSL.new()
var ink_fill = 0.25


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


func set_ink_color(h, s, l):
	ink_color.hue = h
	ink_color.saturation = s
	ink_color.lightness = l
	%InkMask.modulate = Color.from_ok_hsl(ink_color.hue, ink_color.saturation, ink_color.lightness)


func set_ink_fill(p):
	ink_fill = p
	%InkMask.position.y = 128 * (1 - ink_fill)


func goto(pos):
	paused = false
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
			ink_fill = ink_fill,
			h = ink_color.hue,
			s = ink_color.saturation,
			l = ink_color.lightness,
		}
	Global.persistant.creation_aye = obj
	return obj
