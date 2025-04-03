extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var moved = false
	if Input.is_action_pressed("ui_left"):
		moved = true
		flip_h = true
		position.x += -4
	if Input.is_action_pressed("ui_right"):
		moved = true
		flip_h = false
		position.x += 4
	if Input.is_action_pressed("ui_up"):
		moved = true
		position.y += -4
	if Input.is_action_pressed("ui_down"):
		moved = true
		position.y += 4

	if moved:
		if not is_playing(): play()
		offset = Vector2.ZERO
	else:
		if is_playing(): pause()
		if (Global.session.drawnumber % 30 == 1) or (Global.session.drawnumber % 30 == 7):
			offset.y += 4
		elif (Global.session.drawnumber % 30 == 15) or (Global.session.drawnumber % 30 == 22):
			offset.y -= 4

	position = pixel_snap(position)


func pixel_snap(v: Vector2):
	v.x = int(v.x + 1024) % 1024
	v.y = int(v.y + 1024) % 1024
	v = floor(v / 4) * 4
	return v
