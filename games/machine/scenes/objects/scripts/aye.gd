extends Area2D

const gut_scene = preload("res://games/machine/scenes/objects/gut.tscn")

var _gravity: Vector2
var velocity: Vector2
var angular_velocity = 0

var radius:
	get():
		return %CollisionShape2D.shape.radius * abs(scale.y)
	set(v):
		%CollisionShape2D.shape.radius = v

var state = "jump"
var touching_cogs = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for cog in touching_cogs:
		aye_meets_cog(self, cog)

	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var pos_diff: Vector2
	var angle_diff = angle_difference(0, _gravity.angle() - (PI / 2) - rotation) * 0.333
	rotation += angle_diff
	rotation = angle_difference(0, rotation)
	if scale.y < 0.125: respawn()
	scale.x = scale.y

	if touching_cogs.size() >= 2:
		var clockwise = touching_cogs[0]
		var anticlockwise = touching_cogs[0]
		for cog in touching_cogs:
			if cog.rotation_speed > clockwise.rotation_speed: clockwise = cog
			if cog.rotation_speed < anticlockwise.rotation_speed: anticlockwise = cog
		if clockwise != anticlockwise:
			var ang = (anticlockwise.position - clockwise.position).angle()
			ang -= (position - clockwise.position).angle()
			ang = angle_difference(0, ang)
			if ang > 0: state = "die"

	%AnimatedSprite2D.speed_scale = 1
	if state != "die":
		if scale.y < 1: scale.y += 0.03125
		if state == "jump":
			if round(dir.y) > 0: stomp()
		elif state != "stomp":
			if dir.x:
				state = "walk"
				%AnimatedSprite2D.flip_h = dir.x < 0
				%AnimatedSprite2D.speed_scale = abs(dir.x)
				velocity = _gravity.rotated(-PI / 2).normalized() * (dir.x * 8)
				velocity += _gravity
			else:
				state = "idle"
			if round(dir.y) < 0: jump()
	else:
		scale.y -= 0.03125

	velocity += _gravity
	position += velocity
	rotation += angular_velocity

	var camera = get_parent().camera
	pos_diff = (position - camera.position) * 0.125
	camera.position += pos_diff
	angle_diff = angle_difference(0, rotation - camera.rotation) * 0.125
	camera.rotation = angle_difference(0, camera.rotation + angle_diff)

	match state:
		"jump":
			var a = angle_difference(0, velocity.angle() - _gravity.angle())
			if abs(a) > PI / 2:
				%AnimatedSprite2D.play("jump")
			elif %AnimatedSprite2D.animation == "jump":
				%AnimatedSprite2D.play("apex")
				await %AnimatedSprite2D.animation_finished
				%AnimatedSprite2D.play("fall")

		"stomp":
			%AnimatedSprite2D.play("stomp")

		"walk":
			%AnimatedSprite2D.play("walk")

		"die":
			%AnimatedSprite2D.play("die")
			if randf() < 0.3333:
				var gut = gut_scene.instantiate()
				gut.position = position
				get_parent().add_child(gut)

		_:
			%AnimatedSprite2D.play("idle")

	#return super.render();


func jump():
	if state == "jump": return
	_gravity *= -16
	state = "jump"


func stomp():
	if state == "stomp": return
	velocity.x = 0
	velocity.y = 32
	velocity = velocity.rotated(rotation)
	state = "stomp"


func respawn():
	position.x = randf() * 2880
	position.y = randf() * 2880
	state = "stomp"
	%AnimatedSprite2D.play("jump")


func snap_to_edge(obstruction: Node, overlap = 0):
	var x = 0
	var y = INF
	var l = null

	x = position.x - obstruction.position.x
	y = position.y - obstruction.position.y
	l = sqrt(pow(x, 2) + pow(y, 2))
	l /= radius + obstruction.radius - overlap
	x /= l
	y /= l
	if not x: x = 0
	if not y: y = 0
	position = obstruction.position + Vector2(x, y)


func aye_meets_cog(aye: Node, cog: Node):
	if aye.state == "stomp":
		cog.snap_to_edge(aye)
		cog.inactive += 8
	else:
		aye.snap_to_edge(cog, 1)
		if !cog.rotation_speed && !cog.inactive: cog.angular_velocity = randf_range(PI / 180, PI / 90)
	aye.velocity = Vector2.ZERO
	if aye.state == "jump" || aye.state == "stomp": aye.state = "idle"
	aye.position = (aye.position - cog.position).rotated(cog.rotation_speed) + cog.position


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("cog"):
		if not touching_cogs.has(area): touching_cogs.push_back(area)


func _on_area_exited(area: Area2D) -> void:
	touching_cogs.erase(area)
