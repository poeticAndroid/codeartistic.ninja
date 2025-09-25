@tool
extends Area2D

@export var type = 0:
	set(v):
		type = v
		if not %AnimatedSprite2D: await ready
		%AnimatedSprite2D.frame = type
		match type:
			0: radius = 92 / 2 - 12
			1: radius = 138 / 2 - 12
			2: radius = 184 / 2 - 12
			3: radius = 230 / 2 - 12
			4: radius = 276 / 2 - 12
			5: radius = 321 / 2 - 12
			6: radius = 367 / 2 - 12

var angular_velocity = 0.1

var touching_cogs = []

var leader: Node

var teeth = 0
var inactive = 128
var _size = 0
var _prerotation

var radius:
	get():
		return %CollisionShape2D.shape.radius * abs(scale.y)
	set(v):
		%CollisionShape2D.shape.radius = v

var circumference:
	get():
		return PI * 2 * radius

var rotation_speed:
	get():
		angular_velocity = angle_difference(0, angular_velocity)
		if angular_velocity: return angular_velocity
		remove_leader_loops()
		if leader:
			return -leader.rotation_speed * (leader.teeth / teeth)
		return 0

var edge_speed:
	get():
		return (rotation_speed / PI * 2) * circumference


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_size = radius * 2
	teeth = round(circumference / (12 * 3 * 2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	for cog in touching_cogs:
		cog_meets_cog(self, cog)

	if inactive:
		inactive -= 1
		if leader: leader.inactive = inactive
		leader = null
		_prerotation = null
		angular_velocity = 0
		if radius * 2 < _size:
			radius = _size / 2
		radius += 4

	rotation += angular_velocity

	remove_leader_loops()
	if leader:
		radius = _size / 2
		if rotation_speed == 0:
			inactive += 1
		if _prerotation == null:
			var v = position - leader.position
			var a = atan2(v.x, -v.y)
			_prerotation = a + a * (leader.teeth / teeth)

		rotation = _prerotation - leader.rotation * (leader.teeth / teeth)
		process_priority = leader.process_priority - 1
		angular_velocity = 0
	else:
		_prerotation = null

	#rotation = angle_difference(0, rotation)


func cog_meets_cog(cog1: Node, cog2: Node):
	if cog1.inactive:
		cog1.snap_to_edge(cog2, 1)
	if cog2.leader: cog2.snap_to_edge(cog2.leader, 1)
	if cog1.inactive || cog2.inactive || cog2.leader: return
	if (cog1.leader && cog1.leader != cog2) || cog1.angular_velocity:
		cog2.leader = cog1


func snap_to_edge(obstruction: Node, overlap = 0):
	radius = _size / 2

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


func remove_leader_loops():
	var chain = []
	var cog = self
	while cog:
		if chain.has(cog):
			while cog:
				cog.leader = null
				cog.inactive = 8
				cog = chain.pop_back()
			return
		chain.push_back(cog)
		cog = cog.leader


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("cog"):
		if not touching_cogs.has(area): touching_cogs.push_back(area)


func _on_area_exited(area: Area2D) -> void:
	touching_cogs.erase(area)
