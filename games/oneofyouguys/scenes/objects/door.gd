@tool
extends Node2D

@onready var color_rect: ColorRect = $ColorRect

@export var clan: Clan:
	set(_clan):
		clan = _clan
		if not color_rect: return
		match clan:
			Clan.RANDOM:
				color_rect.modulate = Color.WHITE
			Clan.ORANGE:
				color_rect.modulate = Color("FF9200")
			Clan.GREEN:
				color_rect.modulate = Color("74FF00")
			Clan.PURPLE:
				color_rect.modulate = Color("6E01FF")
@export var size: Vector2 = Vector2.ONE:
	set(_size):
		size = _size
		if not color_rect: return
		color_rect.size = size
		color_rect.position = size * -0.5

enum Clan {RANDOM, ORANGE, GREEN, PURPLE}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	if clan == Clan.RANDOM:
		clan = randi_range(1, 3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
