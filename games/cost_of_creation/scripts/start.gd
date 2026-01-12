extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("user://creation")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_credits_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)


func _on_play_btn_pressed() -> void:
	Global.goto_scene("./scenes/browser")
