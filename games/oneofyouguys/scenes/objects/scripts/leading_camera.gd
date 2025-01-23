extends Camera2D

@export var sight: Vector2
@export var speed_scale: Vector2 = Vector2(2, 2)
@export var limit: ColorRect
@export var follow_group: String = "player"

var subject: Node2D

var _speed: Vector2
var _direction: Vector2

var _last_pos: Vector2
var _current: Vector2
var _subject_center: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not sight: sight = get_viewport_rect().size / 5
	$Area2D/CollisionShape2D.shape.size = get_viewport_rect().size

	subject = get_tree().get_first_node_in_group(follow_group)
	if subject:
		_last_pos = subject.position
		_current = subject.position
		_subject_center = subject.position

	_speed = Vector2.ZERO
	_direction = Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var _subject = get_tree().get_first_node_in_group(follow_group)
	if subject != _subject:
		subject = _subject
		_speed = Vector2.ZERO
		if subject:
			_last_pos = subject.position
	if subject:
		_direction = subject.position - _last_pos
		_subject_center = subject.position
		_current = _current.clamp(_subject_center - sight, _subject_center + sight)
		_last_pos = subject.position

	if abs(_speed.x) < abs(_direction.x * speed_scale.x):
		_speed.x = _direction.x * speed_scale.x
	else:
		_speed.x *= .97
	if abs(_speed.y) < abs(_direction.y * speed_scale.y):
		_speed.y = _direction.y * speed_scale.y
	else:
		_speed.y *= .97
	_current += _speed

	if limit:
		var center: Vector2 = get_viewport_rect().size / 2
		_current = _current.clamp(limit.position + center, limit.position + limit.size - center)
		if get_viewport_rect().size.x > limit.size.x:
			_current.x = limit.position.x + limit.size.x / 2
		if get_viewport_rect().size.y > limit.size.y:
			_current.y = limit.position.y + limit.size.y / 2
	position = _current.round()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_signal("on_screen"):
		body.emit_signal("on_screen")
