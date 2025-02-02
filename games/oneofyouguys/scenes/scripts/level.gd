extends Node2D

var bullet_scene = preload("res://games/oneofyouguys/scenes/objects/bullet.tscn")
var bullet_pool = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 60
	if Global.scene_name.get_file() != "start":
		Global.persistant["oneofyouguys_checkpoint"] = Global.scene_name.get_file()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func shoot(shooter: Node2D, from: Vector2, speed: Vector2, ttl: float):
	var bullet: Node2D
	if bullet_pool.size():
		bullet = bullet_pool.pop_back()
	else:
		bullet = bullet_scene.instantiate()
		add_child(bullet)
	bullet.shooter = shooter
	bullet.position = from
	bullet.speed = speed
	bullet.enable()
	await get_tree().create_timer(ttl).timeout
	bullet.disable()
	bullet_pool.push_back(bullet)

