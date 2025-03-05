extends Control

signal step

var line: String
var tree: TextTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emit_signal("step")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
