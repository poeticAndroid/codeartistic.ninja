extends Area2D

var velocity = Vector2(randf_range(-4, 4), randf_range(-4, 4))
var angular_velocity = randf_range(-0.4, 0.4)

var taken = false
var growing = false

var overlapping_ship = []
var overlapping_anx = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(-32, randf_range(0, 540))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if growing:
		scale += Vector2(0.1, 0.1)
		if scale.x > 32: explode()

	for ship in overlapping_ship:
		scale += Vector2(0.1, 0.1)
		if scale.x > 32: explode()
	for anx in overlapping_anx:
		if scale.x < anx.scale.x:
			explode()

	position += velocity
	rotation += angular_velocity


func explode():
	if taken: return
	taken = true
	%ExplosionSnd.play()
	get_tree().create_tween().tween_property(self, "modulate:a", 0, 0.5)
	await get_tree().create_tween().tween_property(self, "scale", Vector2(2, 2), 0.5).finished
	queue_free()


func _on_area_entered(thing: Area2D) -> void:
	if thing.is_in_group("joy"): explode()
	if thing.is_in_group("ship") and not overlapping_ship.has(thing):
		overlapping_ship.push_back(thing)
	if thing.is_in_group("anx") and not overlapping_anx.has(thing):
		overlapping_anx.push_back(thing)


func _on_area_exited(thing: Area2D) -> void:
	overlapping_ship.erase(thing)
	overlapping_anx.erase(thing)
