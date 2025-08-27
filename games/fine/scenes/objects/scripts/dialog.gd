extends Label

signal finished

var orig_pos: Vector2
var queue = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	orig_pos = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if visible_characters > 1 and visible_characters < text.length():
			visible_characters = text.length()
		elif visible_characters > 1:
			if queue.size():
				text = queue.pop_front()
				visible_characters = 0
			else:
				text = ""
				emit_signal("finished")
	visible_characters += 1
	position = orig_pos
	position.x += randf()
	position.y += randf()


func say(message: String):
	queue.clear()
	var parts = message.split("\n")
	for part in parts:
		queue.push_back(part)
	text = queue.pop_front()
	visible_characters = 0
	return finished
