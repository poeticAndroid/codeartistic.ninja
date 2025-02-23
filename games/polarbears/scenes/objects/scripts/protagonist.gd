@icon("./icons/protagonist.png")
class_name Protagonist
extends Area2D

static var scene = preload("../protagonist.tscn")
static func create(_recording = [], _record = false):
	var inst = scene.instantiate()
	inst.position = Vector2(0, 171)
	inst.recording = _recording
	inst.record = _record
	return inst

var velocity = Vector2.ZERO
var max_velocity = 300.0
var recording = []
var record: bool
var recpos = 0

var bullet_pool = []
var bullet_speed: float
var bullet_max_travel: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bullet = Bullet.create(position, bullet_pool)
	bullet_pool.push_back(bullet)
	bullet_speed = bullet.speed
	bullet_max_travel = bullet.max_travel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if record and collision_layer:
		while recording.size() <= recpos: recording.push_back(null)
		recording[recpos] = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * max_velocity
	if recording.size() > recpos:
		velocity = recording[recpos]
	else:
		die()
	position += velocity / 60
	position = position.clamp(Vector2(-480, -270), Vector2(480, 270))

	recpos += 1
	$AnimatedSprite2D.position = position.round() - position


func die():
	if $AnimatedSprite2D.animation == "die": return
	collision_layer = 0
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	if record: Global.reload_current_scene(true)
	queue_free()


func shoot():
	if not bullet_pool.size(): return
	var node = $"."
	while node:
		if node.has_method("add_bullet"):
			var bullet = bullet_pool.pop_back()
			bullet.speed = bullet_speed
			bullet.max_travel = bullet_max_travel
			return node.add_bullet(bullet.enable(global_position + Vector2(0, -32)))
		node = node.get_parent()


func upgrade(point = 1):
	var chance = randf()
	if chance < 0.5:
		for i in range(point):
			bullet_pool.push_back(Bullet.create(position + Vector2(0, -32), bullet_pool))
	elif chance < 0.6:
		$gunTimer.wait_time *= pow(0.9, point)
	elif chance < 0.7:
		bullet_speed += point * 5
	elif chance < 0.8:
		bullet_max_travel += point * 5
	elif chance < 0.9:
		for i in range(point):
			bullet_pool.push_back(Bullet.create(position + Vector2(0, -32), bullet_pool))
		$gunTimer.wait_time *= pow(0.9, point)
		bullet_speed += point * 5
		bullet_max_travel += point * 5


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		die()
