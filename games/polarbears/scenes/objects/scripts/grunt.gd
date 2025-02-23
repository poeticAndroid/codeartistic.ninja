@icon("./icons/grunt.png")
extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$AnimatedSprite2D.position = position.round() - position


func die():
	if $AnimatedSprite2D.animation == "die": return false
	collision_layer = 0
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	queue_free()
