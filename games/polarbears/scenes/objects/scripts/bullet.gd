@icon("./icons/bullet.png")
class_name Bullet
extends Area2D

static var bullet_pool = []
static var scene = preload("../bullet.tscn")
static func create(pos: Vector2, pool = Bullet.bullet_pool):
	var inst = bullet_pool.pop_back()
	if not inst: inst = scene.instantiate()
	inst.pool = pool
	inst.enable(pos)
	return inst

var speed = 400.0
var max_travel = 350.0
var start_pos: Vector2
var pool: Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not visible: return
	position.y -= speed / 60
	if start_pos.distance_to(position) > max_travel:
		disable()


func enable(pos: Vector2):
	collision_layer = 1
	visible = true
	position = pos
	start_pos = position
	return self


func disable():
	collision_layer = 0
	visible = false
	if not pool.has(self):
		pool.push_back(self)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		if area.has_method("die"):
			area.die()
			var chance = randf()
			if chance < 0.1:
				add_sibling(Powerup.create(area.position))
		else:
			area.queue_free()
		disable()
