extends Area2D

var velocity = Vector2(0, -4)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	rotation += dir.x * 0.25
	if dir.y < 0:
		velocity.x += -sin(rotation) * dir.y
		velocity.y += cos(rotation) * dir.y
	elif velocity.length():
		velocity *= (velocity.length() - dir.y) / velocity.length()

	position += velocity
	velocity *= 0.99
