@tool
@icon("./icons/text.png")
extends Node2D

@export var cols: int = 24:
	set(_cols):
		cols = _cols
		$Label.size.x = $Label.label_settings.font_size * cols
@export var center: bool = false
@export_multiline var text: String = "[txt]":
	set(_text):
		text = _text
		$Label.text = text

		var txt = JSON.parse_string(text)
		if typeof(txt) == TYPE_STRING:
			text = txt.replace("\n", "\n ")
		if typeof(txt) == TYPE_ARRAY:
			desktop_text = txt[Global.DESKTOP_INPUT].replace("\n", "\n ")
			touch_text = txt[Global.TOUCH_INPUT].replace("\n", "\n ")
			gamepad_text = txt[Global.GAMEPAD_INPUT].replace("\n", "\n ")
			text = "[ctrl]"

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
