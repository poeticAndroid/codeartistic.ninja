extends Area2D

var velocity = Vector2(0, -4)
var ammo: Array = []
var taken = true

var overlapping_pills = []
var overlapping_anx = []


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

	while ammo.back() and not is_instance_valid(ammo.back()): ammo.pop_back()
	if Input.is_action_just_pressed("ui_accept"): fire()

	for pill in overlapping_pills:
		pill.taken = true
		if not ammo.has(pill):
			ammo.push_back(pill)
			if ammo.size() < 14:
				get_parent().spawn_anx()

	for anx in overlapping_anx:
		if anx.scale.x > 2.2:
			if ammo.size(): ammo.pop_back().taken = false

	position += velocity
	velocity *= 0.99


func fire():
	if ammo.size():
		ammo.pop_back().consume()
		get_parent().spawn_joy()
	else:
		%ClickSnd.play()


func _on_area_entered(thing: Area2D) -> void:
	if thing.is_in_group("pill") and not overlapping_pills.has(thing):
		overlapping_pills.push_back(thing)
	if thing.is_in_group("anx") and not overlapping_anx.has(thing):
		overlapping_anx.push_back(thing)


func _on_area_exited(thing: Area2D) -> void:
	overlapping_pills.erase(thing)
	overlapping_anx.erase(thing)
