@icon("./icons/grunt.png")
extends Area2D

signal on_screen

var velocity = Vector2.ZERO
var max_velocity = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target = get_tree().get_nodes_in_group("protagonist").back()
	if target and collision_layer:
		velocity = target.global_position - global_position
		velocity = velocity.normalized() * max_velocity

	position += velocity / 60
	$AnimatedSprite2D.position = position.round() - position


func die():
	if $AnimatedSprite2D.animation == "die": return false
	collision_layer = 0
	$AnimatedSprite2D.play("die")
	$CPUParticles2D.emitting = true
	$SplatSfx.play()
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.visible = false
	if $CPUParticles2D.emitting == true: await $CPUParticles2D.finished
	queue_free()


func _on_on_screen() -> void:
	max_velocity = 120.0
