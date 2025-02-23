@icon("./icons/protagonist.png")
class_name Protagonist
extends Area2D

static var scene = preload("../protagonist.tscn")
static func create(_recording = [], _record = false):
	var inst = scene.instantiate()
	inst.position = Vector2(0, 171)
	inst.recording = _recording
	inst.record = _record
	return inst

var velocity = Vector2.ZERO
var max_velocity = 300.0
var recording = []
var record: bool
var recpos = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if record:
		while recording.size() <= recpos: recording.push_back(null)
		recording[recpos] = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * max_velocity
	if recording.size() > recpos:
		velocity = recording[recpos]
	else:
		die()
	position += velocity / 60
	position = position.clamp(Vector2(-480, -270), Vector2(480, 270))

	recpos += 1
	$AnimatedSprite2D.position = position.round() - position


func die():
	if $AnimatedSprite2D.animation == "die": return
	monitoring = false
	monitorable = false
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	queue_free()
