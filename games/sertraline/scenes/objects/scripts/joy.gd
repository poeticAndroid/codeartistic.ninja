extends Area2D

var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = get_parent().ship.position
	rotation = get_parent().ship.rotation
	velocity = Vector2(sin(rotation) * 16, -cos(rotation) * 16)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	modulate.a -= 0.02
	if modulate.a <= 0.1:
		queue_free()

	position += velocity


func _on_area_entered(thing: Area2D) -> void:
	if thing.is_in_group("anx"):
		if get_parent().ship.ammo.size() < 128: get_parent().spawn_pill()
		queue_free()
