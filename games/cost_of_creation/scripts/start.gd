extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%WakeUpCall.request("https://hotater-eu.onrender.com/")
	DirAccess.make_dir_recursive_absolute("user://cost_of_creation")
	for _dir in DirAccess.get_directories_at("user://cost_of_creation"):
		if DirAccess.get_files_at("user://cost_of_creation/" + _dir).size() < 4:
			for _file in DirAccess.get_files_at("user://cost_of_creation/" + _dir):
				DirAccess.remove_absolute("user://cost_of_creation/" + _dir + "/" + _file)
			DirAccess.remove_absolute("user://cost_of_creation/" + _dir)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_credits_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)


func _on_play_btn_pressed() -> void:
	Global.goto_scene("./scenes/browser")
