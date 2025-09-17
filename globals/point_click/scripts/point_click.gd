extends Node2D

@export var player: Node2D
var target
var dir
var _lastDist: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TouchControls.rc_mode = false
	TouchControls.send_axis(JOY_AXIS_LEFT_X, 0)
	TouchControls.send_axis(JOY_AXIS_LEFT_Y, 0)
	TouchControls.send_action("ui_accept", false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not target: return
	var dist = player.position.distance_to(target)
	if dist < _lastDist:
		TouchControls.send_axis(JOY_AXIS_LEFT_X, dir.x)
		TouchControls.send_axis(JOY_AXIS_LEFT_Y, dir.y)
	else:
		target = null
		TouchControls.send_axis(JOY_AXIS_LEFT_X, 0)
		TouchControls.send_axis(JOY_AXIS_LEFT_Y, 0)
		TouchControls.send_action("ui_accept", true)
		await get_tree().create_timer(0.25).timeout
		TouchControls.send_action("ui_accept", false)
	_lastDist = dist


func goto(t):
	target = t
	dir = player.position.direction_to(target).normalized()
	_lastDist = player.position.distance_to(target) * 2


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		goto(event.position)
