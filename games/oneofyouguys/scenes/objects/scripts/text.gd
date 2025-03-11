@tool
@icon("./icons/text.png")
extends Node2D

@export var cols: int = 24:
	set(_cols):
		cols = _cols
		$Label.size.x = $Label.label_settings.font_size * cols
@export var size: float = 1:
	set(_size):
		size = _size
		$Label.scale = Vector2.ONE * size
@export var center: bool = false:
	set(_center):
		center = _center
		$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
@export_multiline var text: String = "[txt]":
	set(_text):
		text = _text
		$Label.text = text

@export_group("Control hints")
@export_multiline var desktop_text: String
@export_multiline var touch_text: String
@export_multiline var gamepad_text: String

var input_method: int = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if input_method == Global.input_method: return
	input_method = Global.input_method
	match input_method:
		Global.DESKTOP_INPUT:
			$Label.text = desktop_text if desktop_text else text
		Global.TOUCH_INPUT:
			$Label.text = touch_text if touch_text else text
		Global.GAMEPAD_INPUT:
			$Label.text = gamepad_text if gamepad_text else text
