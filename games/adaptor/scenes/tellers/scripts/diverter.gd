extends Control

signal endsub
signal gosub
signal goto

var line: String
var tree: TextTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if line == "^": emit_signal("endsub")
	elif line.ends_with(" ^"): emit_signal("gosub", line.left(-1).strip_edges())
	else: emit_signal("goto", line)
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
