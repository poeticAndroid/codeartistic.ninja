@tool
extends Node2D

@export var clan: Clan:
	set(_clan):
		clan = _clan
		match clan:
			Clan.RANDOM:
				$AnimatedSprite2D.modulate = Color.WHITE
			Clan.ORANGE:
				$AnimatedSprite2D.modulate = Color("FF9200")
			Clan.GREEN:
				$AnimatedSprite2D.modulate = Color("74FF00")
			Clan.PURPLE:
				$AnimatedSprite2D.modulate = Color("6E01FF")
@export var possessed: bool

enum Clan {RANDOM, ORANGE, GREEN, PURPLE}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	if clan == Clan.RANDOM:
		clan = randi_range(1, 3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
