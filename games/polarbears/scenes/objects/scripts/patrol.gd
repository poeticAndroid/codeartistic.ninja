@icon("./icons/patrol.png")
extends Area2D

signal on_screen
signal off_screen

var velocity = Vector2.ZERO
var max_velocity = 250.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.pause()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	if velocity.x == 0:
		$AnimatedSprite2D.play()
		velocity = Vector2(1, -0.125)
		velocity = velocity.normalized() * max_velocity


func _on_off_screen() -> void:
	if not collision_layer: return
	if position.x < 480:
		velocity.x = abs(velocity.x)
		$AnimatedSprite2D.flip_h = false
	else:
		velocity.x = -abs(velocity.x)
		$AnimatedSprite2D.flip_h = true
