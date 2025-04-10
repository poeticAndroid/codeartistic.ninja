extends Node2D

@export var text: String = "You can start typing now.":
	set(_text):
		if text != _text: $AnimationPlayer.play("flash")
		text = _text
		%StatusBar.text = text


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if DisplayServer.is_touchscreen_available():
		position.y = max(62, 540 - DisplayServer.virtual_keyboard_get_height())
