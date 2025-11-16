extends Area2D

var target


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0
	await get_tree().create_tween().tween_property(self, "modulate:a", 1, 2).finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		animate("walk")
		var dir = target - position
		if dir.length() > 96 * delta:
			dir = dir.normalized() * 96 * delta
		else:
			target = null
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


func goto(position):
	target = position


func stop():
	target = null


func leave():
	await get_tree().create_tween().tween_property(self, "modulate:a", 0, 60).finished
	queue_free()
