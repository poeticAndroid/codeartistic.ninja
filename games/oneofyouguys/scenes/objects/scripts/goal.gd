@tool
@icon("./icons/flag_blue.png")
extends Node2D

@export var destination: String
@export var size: Vector2 = Vector2.ONE:
	set(_size):
		size = _size
		if not %ColorRect: await ready
		%ColorRect.size = size
		%ColorRect.position = size * -0.5
		if not $CollisionShape2D: await ready
		$CollisionShape2D.shape = RectangleShape2D.new()
		$CollisionShape2D.shape.size = size


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Body) -> void:
	if body.possessed: Global.replace_scene(destination)
	body.velocity.x *= -1
