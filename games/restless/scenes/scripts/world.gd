extends Node2D

@export var story: JSON

var current_level = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 30
	show_level(current_level)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"): %Camera.position.x += -4
	if Input.is_action_pressed("ui_right"): %Camera.position.x += 4
	if Input.is_action_pressed("ui_up"): %Camera.position.y += -4
	if Input.is_action_pressed("ui_down"): %Camera.position.y += 4
	%Camera.position = pixel_snap(%Camera.position)

	if Input.is_action_just_pressed("ui_accept"):
		current_level += 1
		show_level(current_level)


func pixel_snap(v: Vector2):
	v.x = int(v.x + 1024) % 1024
	v.y = int(v.y + 1024) % 1024
	v = floor(v / 4) * 4
	return v


func show_level(lvl: int):
	if lvl >= story.data.levels.size(): return
	for char in %Characters.get_children():
		char.visible = false
		char.dead = false
		char.talkedto = false
		char.flip_h = false
		var char_data = story.data.levels[lvl].chars
		if char_data.has(char.name):
			char_data = char_data[char.name]
			for prop in char_data:
				char[prop] = char_data[prop]
			char.visible = true
