extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 30
	Global.session.drawnumber = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Global.session.drawnumber += 1

	if (Global.session.drawnumber % 30 == 1) or (Global.session.drawnumber % 30 == 7):
		%Ghost.offset.y += 4
	elif (Global.session.drawnumber % 30 == 15) or (Global.session.drawnumber % 30 == 22):
		%Ghost.offset.y -= 4

	if Input.is_action_just_pressed("ui_accept"):
		Global.goto_scene("./scenes/world")
