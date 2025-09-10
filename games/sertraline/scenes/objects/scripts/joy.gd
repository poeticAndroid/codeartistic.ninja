extends Area2D

var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2(sin(rotation) * 16, -cos(rotation) * 16)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	modulate.a -= 0.02
	if modulate.a <= 0.1:
		queue_free()

	position += velocity
