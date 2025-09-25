extends Node2D

const cog_scene = preload("res://games/machine/scenes/objects/cog.tscn")

@onready var camera = %Camera2D
@onready var aye: Area2D = %Aye

var counts = [32, 64, 64, 16, 8, 4, 2]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 12


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(counts.size()):
		if counts[i]:
			var cog = cog_scene.instantiate()
			cog.position.x = randf_range(0, 2880)
			cog.position.y = randf_range(0, 2880)
			cog.type = randi_range(0, 6)
			add_child(cog)
			counts[i] -= 1

	#if (!this.actorsByType["Cog"]) return super.update();
	var diff: Vector2
	aye._gravity = Vector2.ZERO

	var closest_cogs = []
	var closes_dists = []
	for cog in get_children():
		if not cog.is_in_group("cog"): continue
		diff = cog.position - aye.position
		var l = diff.length() - min(cog.radius, diff.length() - 1)
		diff = diff.normalized() * l
		var i = closest_cogs.size()
		while i > 0 and closes_dists[i - 1] > diff.length(): i -= 1
		closest_cogs.insert(i, cog)
		closes_dists.insert(i, diff.length())
		if closest_cogs.size() > 2:
			closest_cogs.pop_back()
			closes_dists.pop_back()
	var dist_sum = 0
	for dist in closes_dists:
		dist_sum += dist
	for cog in closest_cogs:
		diff = cog.position - aye.position
		if closes_dists.size(): diff = diff.normalized() * closes_dists.pop_back()
		else: diff = diff.normalized() * dist_sum
		aye._gravity += diff
	aye._gravity = aye._gravity.normalized()
