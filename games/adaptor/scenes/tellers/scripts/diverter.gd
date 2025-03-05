extends Control

var story: Node
var line: String
var tree: TextTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if line == "^": story.endsub()
	elif line.ends_with(" ^"): story.gosub(line.left(-1).strip_edges())
	else: story.goto(line)
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
