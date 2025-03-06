extends Control

var story: Node
var line: String
var tree: TextTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	story.new_passage()
	story.goto("0")
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
