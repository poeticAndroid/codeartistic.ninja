extends AnimatedSprite2D

@export var sprite: int:
	set(val):
		sprite = val
		frame = val
@export var x: float:
	set(val):
		position.x = val * 32
@export var y: float:
	set(val):
		position.y = val * 32
@export var maxsprite: int
@export var repititionnumber: int

@export var dead: bool

@export var talkedto: bool
@export var lines = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Global.session.drawnumber % 30) == 1:
		if (randf() * 5) < 2:
			if not dead: flip_h = not flip_h
	if name == "animal":
		if Global.session.drawnumber % 20 == 1:
			frame += 1
			if frame >= maxsprite:
				repititionnumber -= 1
				frame = maxsprite - 2
			if repititionnumber < 1:
				frame = sprite + randi_range(0, 2)
				repititionnumber = randi_range(1, 3)
				moverandomdirection()
	position = pixel_snap(position)


func moverandomdirection():
	var direction = randi_range(0, 3)
	if direction < 1:
		position.x += 1
	elif direction < 2:
		position.x -= 1
	elif direction < 3:
		position.y -= 1
	else:
		position.y += 1


func pixel_snap(v: Vector2):
	v.x = int(v.x + 1024) % 1024
	v.y = int(v.y + 1024) % 1024
	v = floor(v / 4) * 4
	return v
