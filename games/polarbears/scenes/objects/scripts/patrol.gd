@icon("./icons/patrol.png")
extends Node2D

signal on_screen
signal off_screen

var velocity = Vector2.ZERO
var max_velocity = 250.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity / 60
	$AnimatedSprite2D.position = position.round() - position


func _on_on_screen() -> void:
	if velocity.x == 0:
		velocity = Vector2(1, -.125)
		velocity = velocity.normalized() * max_velocity


func _on_off_screen() -> void:
	velocity.x *= -1
	$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
