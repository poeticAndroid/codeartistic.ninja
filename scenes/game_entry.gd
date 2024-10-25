extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var node = $Node2D/Button
	node.pivot_offset = node.size / 2
	node.rotation += randf_range(-PI / 90, PI / 90)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
