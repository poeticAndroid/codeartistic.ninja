extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 12


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	warp()


func warp():
	for node in get_children():
		var r = node.scale.length() * 32
		if node.position.x < -r: node.position.x += 960 + r * 2
		if node.position.y < -r: node.position.y += 540 + r * 2
		if node.position.x > 960 + r: node.position.x -= 960 + r * 2
		if node.position.y > 540 + r: node.position.y -= 540 + r * 2
