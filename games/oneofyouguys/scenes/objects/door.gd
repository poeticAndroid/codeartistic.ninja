@tool
extends Node2D

@export var clan: Clan:
	set(_clan):
		clan = _clan
		if not $ColorRect: await ready
		match clan:
			Clan.RANDOM:
				$ColorRect.modulate = Color.WHITE
			Clan.ORANGE:
				$ColorRect.modulate = Color("FF9200")
			Clan.GREEN:
				$ColorRect.modulate = Color("74FF00")
			Clan.PURPLE:
				$ColorRect.modulate = Color("6E01FF")
@export var size: Vector2 = Vector2.ONE:
	set(_size):
		size = _size
		if not $ColorRect: await ready
		$ColorRect.size = size
		$ColorRect.position = size * -0.5

enum Clan {RANDOM, ORANGE, GREEN, PURPLE}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	if clan == Clan.RANDOM:
		clan = randi_range(1, 3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
