extends Node2D

@onready var aye: CharacterBody2D = %Aye

var pill_scene = preload("res://games/emotions/scenes/objects/pill.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 12
	await get_tree().create_timer(10).timeout
	dispencePill()


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


func dispencePill():
	add_child(pill_scene.instantiate())
