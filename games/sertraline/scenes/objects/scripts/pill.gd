extends Area2D

var velocity = Vector2(randf_range(-4, 4), randf_range(-4, 4))
var angular_velocity = randf_range(-0.4, 0.4)

var taken:
	set(val):
		if taken == val: return
		taken = val
		if taken:
			%PickupSnd.play()
			get_tree().create_tween().tween_property(self, "scale", Vector2(0.5, 0.5), 0.5)
		else:
			follow = null
			get_tree().create_tween().tween_property(self, "scale", Vector2(1, 1), 1)
var follow: Area2D
var clingy = 128.0
var first:
	set(val):
		first = val
		if first: modulate = Color.RED
		else: modulate = Color.WHITE

var consuming = false

var overlapping_pills = []
var overlapping_anx = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(randf_range(0, 960), -32)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if taken and not is_instance_valid(follow):
		follow = get_parent().ship
	if follow: taken = follow.taken
	else: taken = false
	if follow:
		process_priority = follow.process_priority + 1
		velocity = follow.position - position
		if velocity.length() > 0 and velocity.length() <= clingy:
			velocity *= (velocity.length() - scale.x * 32 - follow.scale.x * 32) / velocity.length()
			if clingy > 128: clingy -= 1
		elif velocity.length() > clingy:
			velocity = follow.velocity
			clingy += 1

		for pill in overlapping_pills:
			if follow == pill.follow:
				follow = pill
	else:
		for anx in overlapping_anx:
			consume()

	position += velocity
	rotation += angular_velocity


func consume():
	if consuming: return
	consuming = true
	first = false
	%ConsumeSnd.play()
	await get_tree().create_tween().tween_property(self, "scale", Vector2(0, 0), 0.5).finished
	queue_free()


func _on_area_entered(thing: Area2D) -> void:
	if thing.is_in_group("pill") and not overlapping_pills.has(thing):
		overlapping_pills.push_back(thing)
	if thing.is_in_group("anx") and not overlapping_anx.has(thing):
		overlapping_anx.push_back(thing)


func _on_area_exited(thing: Area2D) -> void:
	overlapping_pills.erase(thing)
	overlapping_anx.erase(thing)
