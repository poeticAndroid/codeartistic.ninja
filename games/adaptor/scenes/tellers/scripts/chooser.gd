extends Control

signal goto

var line: String
var tree: TextTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emit_signal("goto", "0")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
