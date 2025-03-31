extends Node2D

@export var story: JSON


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(story.data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"): %Camera.position.x += -4
	if Input.is_action_pressed("ui_right"): %Camera.position.x += 4
	if Input.is_action_pressed("ui_up"): %Camera.position.y += -4
	if Input.is_action_pressed("ui_down"): %Camera.position.y += 4
	%Camera.position.x = int(%Camera.position.x + 1024) % 1024
	%Camera.position.y = int(%Camera.position.y + 1024) % 1024
	%Camera.position = floor(%Camera.position / 4) * 4
