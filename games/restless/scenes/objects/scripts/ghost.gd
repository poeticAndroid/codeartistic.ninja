extends AnimatedSprite2D

var listening_to: Array[Node] = []

var closure: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var moved = false
	if Input.is_action_pressed("ui_right"):
		moved = true
		flip_h = false
		position.x += 4
	elif Input.is_action_pressed("ui_left"):
		moved = true
		flip_h = true
		position.x += -4
	if Input.is_action_pressed("ui_down"):
		moved = true
		position.y += 4
	elif Input.is_action_pressed("ui_up"):
		moved = true
		position.y += -4

	if moved:
		if not is_playing(): play()
		offset = Vector2.ZERO
	else:
		if is_playing():
			listening_to.sort_custom(func(a, b): return position.distance_to(a.position) < position.distance_to(b.position))
			pause()
		if (Global.session.drawnumber % 30 == 1) or (Global.session.drawnumber % 30 == 7):
			if closure: offset.x += 4
			else: offset.y += 4
		elif (Global.session.drawnumber % 30 == 15) or (Global.session.drawnumber % 30 == 22):
			if closure: offset.x -= 4
			else: offset.y -= 4

	if closure and Input.is_action_pressed("ui_accept"):
		offset.y -= 2
		if offset.y < -320:
			Global.replace_scene("./end", true)

	position = pixel_snap(position)


func pixel_snap(v: Vector2):
	v.x = int(v.x + 1024) % 1024
	v.y = int(v.y + 1024) % 1024
	v = floor(v / 4) * 4
	return v


func _on_area_2d_area_entered(node: Node2D) -> void:
	while not "lines" in node:
		node = node.get_parent()
	if node.visible:
		listening_to.erase(node)
		listening_to.push_back(node)


func _on_area_2d_area_exited(node: Node2D) -> void:
	while not "lines" in node:
		node = node.get_parent()
	listening_to.erase(node)
