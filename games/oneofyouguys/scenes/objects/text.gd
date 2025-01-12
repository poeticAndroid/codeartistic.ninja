@tool
extends Label

@export var cols: int = 24
@export var center: bool = false
@export var desktop_txt: String
@export var touch_txt: String
@export var gamepad_txt: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if cols > 0:
		size.x = label_settings.font_size * cols
	var txt = JSON.parse_string(text)
	if typeof(txt) == TYPE_STRING:
		text = txt.replace("\n", " \n")
	if typeof(txt) == TYPE_ARRAY:
		desktop_txt = txt[0]
		touch_txt = txt[1]
		gamepad_txt = txt[2]
		text = "[ctrl]"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return

