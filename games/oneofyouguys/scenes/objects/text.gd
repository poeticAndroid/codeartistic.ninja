@tool
extends Label

@export var cols: int = 24
@export var center: bool = false
@export var desktop_txt: String
@export var touch_txt: String
@export var gamepad_txt: String

var input_method: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if cols > 0:
		size.x = label_settings.font_size * cols
	var txt = JSON.parse_string(text)
	if typeof(txt) == TYPE_STRING:
		text = txt.replace("\n", " \n")
	if typeof(txt) == TYPE_ARRAY:
		desktop_txt = txt[Global.DESKTOP_INPUT]
		touch_txt = txt[Global.TOUCH_INPUT]
		gamepad_txt = txt[Global.GAMEPAD_INPUT]
		text = "[ctrl]"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if input_method == Global.input_method: return
	input_method = Global.input_method
	match input_method:
		Global.DESKTOP_INPUT:
			text = desktop_txt if desktop_txt else text
		Global.TOUCH_INPUT:
			text = touch_txt if touch_txt else text
		Global.GAMEPAD_INPUT:
			text = gamepad_txt if gamepad_txt else text
