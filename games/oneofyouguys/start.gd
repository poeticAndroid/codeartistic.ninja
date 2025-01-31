extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var btn = get_tree().get_first_node_in_group("autofocus")
	if btn.has_method("grab_focus"): btn.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_btn_pressed() -> void:
	Global.goto_scene("scenes/" + Global.persistant.get_or_add("oneofyouguys_checkpoint", "tutorial"))


func _on_retry_btn_pressed() -> void:
	Global.go_back(false)


func _on_menu_btn_pressed() -> void:
	Global.persistant.erase("oneofyouguys_checkpoint")
	Global.go_back()
