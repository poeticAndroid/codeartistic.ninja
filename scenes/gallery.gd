extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_released() and not event.is_class("InputEventMouse"):
		var foc = get_tree().root.gui_get_focus_owner()
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		tween.tween_property(%ScrollContainer, "scroll_vertical", %ScrollContainer.scroll_vertical+foc.global_position.y-200, 1)
