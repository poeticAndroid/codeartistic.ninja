@icon("./icons/protagonist.png")
extends Node2D

var scene = preload("../protagonist.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$AnimatedSprite2D.position = position.round() - position
