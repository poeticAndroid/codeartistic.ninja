extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)


func _on_button_pressed() -> void:
	Global.go_back()
