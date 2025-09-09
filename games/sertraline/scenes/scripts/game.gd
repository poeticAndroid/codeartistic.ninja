extends Node2D

@onready var ship: Area2D = %Ship

var pill_scene = preload("res://games/sertraline/scenes/objects/pill.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 12
	TouchControls.engage(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	warp()


func warp():
	for node in get_children():
		if not node is Area2D: continue
		var r = node.scale.x * 32
		if node.position.x < -r: node.position.x += 960 + r * 2
		if node.position.y < -r: node.position.y += 540 + r * 2
		if node.position.x > 960 + r: node.position.x -= 960 + r * 2
		if node.position.y > 540 + r: node.position.y -= 540 + r * 2


func spawn_pill():
	add_child(pill_scene.instantiate())


func _on_challenge_timer_timeout() -> void:
	if get_child_count() < 1024:
		spawn_pill()
		#if (this.ammo.length === 0)this.spawn("Anx");
		%ChallengeTimer.wait_time = 10
	else:
		#this.actorsByType["Ship"][0].shoot();
		%ChallengeTimer.wait_time = 1
