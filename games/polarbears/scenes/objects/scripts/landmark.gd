@tool
@icon("./icons/landmarks.png")
extends Node2D

enum LandmarkType {
	DeathStar,
	Satelite,
	Moon,
	SpaceWhale
}

@export var frame: LandmarkType:
	set(_frame):
		frame = _frame
		$AnimatedSprite2D.frame = frame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$AnimatedSprite2D.position = position.round() - position
