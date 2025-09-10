extends Area2D

var velocity = Vector2(0, -4)
var ammo: Array = []
var taken = true

var pain = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	rotation += dir.x * 0.25
	if dir.y < 0:
		velocity.x += -sin(rotation) * dir.y
		velocity.y += cos(rotation) * dir.y
	elif velocity.length():
		velocity *= (velocity.length() - dir.y) / velocity.length()

	if Input.is_action_just_pressed("ui_accept"): fire()

	if pain and pain.scale.x > 2.2:
		if ammo.size(): ammo.pop_back().taken = false

	position += velocity
	velocity *= 0.99


func fire():
	if ammo.size():
		var pill = ammo.pop_back()
		if ammo.back():
			ammo.back().follow = self
		pill.consume()
		get_parent().spawn_joy()


func _on_area_entered(thing: Area2D) -> void:
	if thing.is_in_group("anx") and not thing.taken:
		pain = thing
	if thing.is_in_group("pill") and not thing.taken:
		thing.follow = self
		if not ammo.has(thing):
			var next = ammo.back()
			ammo.push_back(thing)
			if ammo.size() < 14:
				get_parent().spawn_anx()
			await get_tree().create_timer(10).timeout
			if not is_instance_valid(thing): return
			if not ammo.has(thing): return
			if next:
				if not is_instance_valid(next): return
				if not ammo.has(next): return
				next.follow = thing
				if next.first: thing.first = next.first
				next.first = false
			for pill in ammo:
				if not is_instance_valid(pill): return
				if pill.first: return
			ammo.back().first = true


func _on_area_exited(area: Area2D) -> void:
	pass  # Replace with function body.
