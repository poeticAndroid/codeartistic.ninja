extends Area2D

@export var shooter: Node2D
@export var speed: Vector2 = Vector2.ZERO
var angular_speed: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not visible: return
	position += speed * delta
	rotation += angular_speed * delta


func enable():
	angular_speed = randf_range(-360, 360)
	$CollisionShape2D.disabled = false
	visible = true


func disable():
	$CollisionShape2D.disabled = true
	visible = false


func _on_body_entered(body: Node2D) -> void:
	if body == shooter: return
	if body.has_method("damage"):
		body.damage(.34)
		shooter.traitor = shooter.clan == body.clan
		disable()
