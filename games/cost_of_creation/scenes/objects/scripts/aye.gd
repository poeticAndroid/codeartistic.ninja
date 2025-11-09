extends Area2D

var target


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0
	await get_tree().create_tween().tween_property(self, "modulate:a", 1, 1).finished


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
		%StrokeSprite.flip_h = position.x > target.x
		%FillSprite.flip_h = position.x > target.x


func goto(position):
	target = position


func leave():
	await get_tree().create_tween().tween_property(self, "modulate:a", 0, 8).finished
	queue_free()
