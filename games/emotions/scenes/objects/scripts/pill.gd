extends Area2D

var velocity = Vector2(randf_range(-4, 4), randf_range(-4, 4))
var angular_velocity = randf_range(-0.4, 0.4)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(randf_range(0, 960), -32)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity
	rotation += angular_velocity


func _on_body_entered(body: Node2D) -> void:
	get_parent().aye.get_pill()
	queue_free()
