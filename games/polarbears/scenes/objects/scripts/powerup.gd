@icon("./icons/powerup.png")
class_name Powerup
extends Area2D

static var scene = preload("../powerup.tscn")
static func create(pos: Vector2):
	var inst = scene.instantiate()
	inst.position = pos
	return inst

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$AnimatedSprite2D.position = position.round() - position


func die():
	if collision_layer == 0: return
	collision_layer = 0
	$AnimatedSprite2D.visible = false
	$CPUParticles2D.emitting = true
	await $CPUParticles2D.finished
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("protagonist"):
		get_tree().get_nodes_in_group("protagonist").back().upgrade()
		die()
