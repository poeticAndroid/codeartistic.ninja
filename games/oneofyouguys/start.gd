extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StartBtn.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_btn_pressed() -> void:
	Global.goto_scene("scenes/tutorial")
