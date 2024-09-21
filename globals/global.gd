extends Node2D

var loading: bool
var scene_name: String = "/"
var history: Array = []


func _ready():
	$TransitionAnimations.play_backwards("fade_to_black")
	if not OS.is_debug_build():
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN


func _input(event: InputEvent):
	if event.is_class("InputEventMouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if event.is_action_pressed("ui_cancel"):
		go_back()
	if event.is_action_pressed("toggle_fullscreen"):
		if get_window().mode == Window.MODE_WINDOWED:
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		else:
			get_window().mode = Window.MODE_WINDOWED


func go_back():
	history.pop_back()
	if history.size():
		load_scene(history.pop_back())
	else:
		get_tree().quit()


func replace_scene(name: String):
	history.pop_back()
	load_scene(name)


func load_scene(name: String):
	if name.is_absolute_path():
		name = name.simplify_path()
	else:
		name = scene_name.get_base_dir().path_join(name).simplify_path()
	if loading:
		if name == scene_name:
			push_warning("Already loading " + name)
		else:
			push_warning("Attempt to load " + name + " while loading " + scene_name)
		return false
	assert(FileAccess.file_exists("res:/" + name + ".tscn"), "Scene not found " + name)
	loading = true
	print("Loading scene '" + name + "'")
	scene_name = name
	history.push_back(name)

	$TransitionAnimations.play("fade_to_black")
	await $TransitionAnimations.animation_finished

	get_tree().change_scene_to_file("res:/" + scene_name + ".tscn")
	await get_tree().node_added

	$TransitionAnimations.play_backwards("fade_to_black")
	await $TransitionAnimations.animation_finished
	focus_first(get_tree().current_scene)
	loading = false
	print(scene_name, "loaded!")


func focus_first(parent: Node):
	for node in parent.get_children():
		if node.is_class("Control"):
			node.grab_focus()
			return true
		elif focus_first(node):
			return true
	return false
