@tool
@icon("./icons/text.png")
extends Node2D

@export var cols: int = 24:
	set(_cols):
		cols = _cols
		$Label.size.x = $Label.label_settings.font_size * cols
@export var size: float = 32:
	set(_size):
		size = _size
		$Label.label_settings.font_size = size
@export var center: bool = false:
	set(_center):
		center = _center
		$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
@export_multiline var text: String = "[txt]":
	set(_text):
		text = _text
		$Label.text = text

var input_method: int = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
