extends Area2D

var velocity = Vector2(randf_range(-4, 4), randf_range(-4, 4))
var angular_velocity = randf_range(-0.4, 0.4)

var taken:
	set(val):
		if taken == val: return
		taken = val
		if taken:
			get_tree().create_tween().tween_property(self, "scale", Vector2(0.5, 0.5), 1)
		else:
			follow = null
			get_tree().create_tween().tween_property(self, "scale", Vector2(1, 1), 1)
var follow: Area2D
var clingy = 64.0
var first:
	set(val):
		first = val
		if first: modulate = Color.RED
		else: modulate = Color.WHITE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(randf_range(0, 960), -32)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if follow:
		taken = follow.taken
		process_priority = follow.process_priority + 1
		velocity = follow.position - position
		if velocity.length() > 0 and velocity.length() <= clingy:
			velocity *= (velocity.length() - scale.x * 32 - follow.scale.x * 32) / velocity.length()
			if clingy > 64: clingy -= 1
		elif velocity.length() > clingy:
			velocity = follow.velocity
			clingy += 1

	position += velocity
	rotation += angular_velocity


func reset():
	follow = null
	taken = false
	first = false


func _on_area_entered(thing: Area2D) -> void:
	if not taken: return
	if not first: return
	if thing.is_in_group("pill") and thing.taken and thing.follow == get_parent().ship:
		follow = thing
		thing.first = first
		first = false
