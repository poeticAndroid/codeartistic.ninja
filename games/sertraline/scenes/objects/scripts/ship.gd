extends Area2D

var velocity = Vector2(0, -4)
var ammo: Array = []
var taken = true


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

	position += velocity
	velocity *= 0.99


func _on_area_entered(thing: Area2D) -> void:
	if thing.is_in_group("pill") and not thing.taken:
		thing.follow = self
		if not ammo.has(thing):
			var next = ammo.back()
			ammo.push_back(thing)
			await get_tree().create_timer(10).timeout
			if not is_instance_valid(thing): return
			if not ammo.has(thing): return
			if next:
				if not is_instance_valid(next): return
				if not ammo.has(next): return
				next.follow = thing
				if next.first: thing.first = next.first
				next.first = false
			else:
				thing.first = true
