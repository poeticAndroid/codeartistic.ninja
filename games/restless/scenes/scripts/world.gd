extends Node2D

@export var story: JSON

var current_level = -1
var current_line = 0
var lines = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.session.drawnumber = 0
	Engine.max_fps = 30


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Global.session.drawnumber += 1

	if %DialogBox.visible:
		%Camera.position = %Ghost.position
		if %DialogBox/LineLabel.visible_characters < 4096:
			%DialogBox/LineLabel.visible_characters += 2
		if current_line < 0 or Input.is_action_just_pressed("ui_accept") or Input.is_action_pressed("ui_select"):
			if Input.is_action_pressed("ui_select"):
				current_line = lines.size() - 1
			else:
				current_line += 1
			%DialogBox/LineLabel.visible_characters = 0
			if current_line < lines.size():
				%DialogBox/LineLabel.text = wordwrap(lines[current_line])
				%DialogBox/CharLabel.text = %DialogBox/LineLabel.text
			else:
				%DialogBox.visible = false
				%Map.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		if is_allnpcstalkedto() and %Camera.position.distance_to(%Ghost.position) > 256:
			%Camera.position = %Ghost.position
			current_level += 1
			show_level(current_level)

		if Input.is_action_pressed("ui_left"): %Camera.position.x += -4
		if Input.is_action_pressed("ui_right"): %Camera.position.x += 4
		if Input.is_action_pressed("ui_up"): %Camera.position.y += -4
		if Input.is_action_pressed("ui_down"): %Camera.position.y += 4

		if Input.is_action_just_pressed("ui_accept") and %Ghost.listening_to:
			%Ghost.listening_to.talkedto = true
			set_dialog_colors(%Ghost.listening_to.frame)
			lines = %Ghost.listening_to.lines
			current_line = -1
			%DialogBox.visible = true
			%Map.process_mode = Node.PROCESS_MODE_DISABLED

	%DialogBox/CharLabel.visible_characters = min(%DialogBox/LineLabel.visible_characters, (%DialogBox/LineLabel.text + ":").find(":") + 1)


func show_level(lvl: int):
	if lvl >= story.data.size(): return
	if story.data[lvl].has("help"):
		%HelpBox.visible = true
		%HelpBox/Label.text = story.data[lvl].help
	else:
		%HelpBox.visible = false
	for char in %Characters.get_children():
		char.visible = false
		char.dead = false
		char.flip_h = false
		char.talkedto = true
		var char_data = story.data[lvl].chars
		if char_data.has(char.name):
			char_data = char_data[char.name]
			char.talkedto = false
			for prop in char_data:
				char[prop] = char_data[prop]
			char.visible = true


func is_allnpcstalkedto():
	for char in %Characters.get_children():
		if not char.talkedto: return false
	return true


func wordwrap(txt: String, w: int = 32):
	var p = 0
	var word = ""
	var out = ""
	for i in range(0, txt.length()):
		var c = txt.substr(i, 1)
		p += 1
		word = word + c
		if p > w:
			out = out + "\n"
			p = word.length()
		if c == " ":
			out = out + word
			word = ""
	out = out + word
	return out


func set_dialog_colors(sprite: int):
	match sprite:
		82:
			%DialogBox/CharLabel.modulate = PicoColors[14]
			%DialogBox/LineLabel.modulate = PicoColors[15]
		66:
			%DialogBox/CharLabel.modulate = PicoColors[2]
			%DialogBox/LineLabel.modulate = PicoColors[8]
		67:
			%DialogBox/CharLabel.modulate = PicoColors[9]
			%DialogBox/LineLabel.modulate = PicoColors[10]
		64:
			%DialogBox/CharLabel.modulate = PicoColors[5]
			%DialogBox/LineLabel.modulate = PicoColors[6]
		68:
			%DialogBox/CharLabel.modulate = PicoColors[1]
			%DialogBox/LineLabel.modulate = PicoColors[13]
		65:
			%DialogBox/CharLabel.modulate = PicoColors[3]
			%DialogBox/LineLabel.modulate = PicoColors[11]
		_:
			%DialogBox/CharLabel.modulate = PicoColors[6]
			%DialogBox/LineLabel.modulate = PicoColors[7]

const PicoColors = [
		Color("#000000"),
		Color("#1d2b53"),
		Color("#7e2553"),
		Color("#008751"),
		Color("#ab5236"),
		Color("#5f574f"),
		Color("#c2c3c7"),
		Color("#fff1e8"),

		Color("#ff004d"),
		Color("#ffa300"),
		Color("#ffec27"),
		Color("#00e436"),
		Color("#29adff"),
		Color("#83769c"),
		Color("#ff77a8"),
		Color("#ffccaa"),
	]
