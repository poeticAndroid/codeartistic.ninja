extends Node2D

var velocity = Vector2.ONE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity *= randf_range(1, 8)
	velocity = velocity.rotated(PI * 2 * randf())
	scale *= 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity
	scale.x += 2.0 / 12.0
	scale.y = scale.x
	modulate.a -= 1.0 / 12.0
	if modulate.a <= 0: queue_free()
