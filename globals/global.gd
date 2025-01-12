extends Node2D

const DESKTOP_INPUT = 0
const TOUCH_INPUT = 1
const GAMEPAD_INPUT = 2

var session: Dictionary = {}
var persistant: Dictionary = {}
var persistant_json: String

var input_method: int = -1

var loading: bool
var scene_name: String = "/start"
var history: Array = []


func _ready():
	$TransitionAnimations.play_backwards("fade_to_black")
	if FileAccess.file_exists("user://persistant.json"):
		persistant = JSON.parse_string(FileAccess.get_file_as_string("user://persistant.json"))
	if not OS.is_debug_build():
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN


func _input(event: InputEvent):
	if event.is_class("InputEventKey"):
		input_method = DESKTOP_INPUT
	if event.is_class("InputEventMouseButton"):
		input_method = DESKTOP_INPUT
	if event.is_class("InputEventScreenTouch"):
		input_method = TOUCH_INPUT
	if event.is_class("InputEventJoypadButton"):
		input_method = GAMEPAD_INPUT

	if event.is_class("InputEventMouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_class("InputEventFromWindow"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	elif event.is_class("InputEventJoypadButton"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	if event.is_action_pressed("ui_cancel"):
		go_back()
	if event.is_action_pressed("toggle_fullscreen"):
		if get_window().mode == Window.MODE_WINDOWED:
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		else:
			get_window().mode = Window.MODE_WINDOWED


func go_back(fade: bool = true):
	if loading:
		return false
	history.pop_back()
	if history.size():
		goto_scene(history.pop_back(), fade)
	elif $ReloadTimer.is_stopped():
		$QuitTip.visible = true
		$ReloadTimer.start()
	else:
		get_tree().quit()


func replace_scene(name: String, fade: bool = false):
	if loading:
		return false
	history.pop_back()
	goto_scene(name, fade)


func goto_scene(name: String, fade: bool = true):
	if loading:
		return false
	loading = true
	if name.is_absolute_path():
		name = name.simplify_path()
	else:
		name = scene_name.get_base_dir().path_join(name).simplify_path()
	assert(FileAccess.file_exists("res:/" + name + ".tscn"), "Scene not found " + name)
	print("Loading scene '" + name + "'")
	scene_name = name
	history.push_back(name)

	if fade:
		$TransitionAnimations.play("fade_to_black")
		await $TransitionAnimations.animation_finished

	$QuitTip.visible = false
	get_tree().change_scene_to_file("res:/" + scene_name + ".tscn")
	await get_tree().node_added

	if fade:
		$TransitionAnimations.play_backwards("fade_to_black")
		await $TransitionAnimations.animation_finished

	loading = false
	print(scene_name, " loaded!")


func save_persistant():
	var file = FileAccess.open("user://persistant.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(persistant, "  "))
	file.close()


func _on_reload_timer_timeout() -> void:
	replace_scene(scene_name, true)


func _on_save_timer_timeout() -> void:
	var json = JSON.stringify(persistant)
	if persistant_json == json: return
	persistant_json = json
	save_persistant()
