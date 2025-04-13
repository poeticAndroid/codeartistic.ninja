extends Node2D

var anxiety = -100.0
var frame: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 24
	TouchControls.engage(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	frame = (frame + 1) % 16
	if frame % 2:
		%Chaos.frame = (%Chaos.frame + 1) % 8
		return

	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir.length():
		if anxiety > 16:
			anxiety += -dir.length()
		%Anx.position += dir * 8
		%Anx.frame = (%Anx.frame + 1) % 4
		if dir.x < 0: %Anx.scale.x = -1
		if dir.x > 0: %Anx.scale.x = +1
	else:
		anxiety += 1
		if Input.is_action_pressed("ui_accept") and anxiety > 200:
			anxiety *= -1
		if anxiety <= -1:
			%Anx.scale = Vector2(sqrt(abs(anxiety)), sqrt(abs(anxiety)))
		%Anx.frame = 2
	%Anx.offset = Vector2(
			anxiety * randf() - anxiety * 0.5,
			anxiety * randf() - anxiety * 0.5
		)
	%Chaos.modulate.a = anxiety / 100
