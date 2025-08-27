extends Area2D

var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%AnimatedSprite2D.speed_scale = randf() + 1
	position.x = randi_range(0, 960)
	position.y = randi_range(0, 540)
	velocity.x = randf_range(-16, 16)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity
	if position.x < -64:
		position.y = randi_range(0, 540)
		velocity.x = abs(velocity.x)
	if position.x > 960 + 64:
		position.y = randi_range(0, 540)
		velocity.x = randf_range(-16, 0)
	%AnimatedSprite2D.flip_h = velocity.x > 0


func _on_body_entered(body: Node2D) -> void:
	velocity.x *= -3
