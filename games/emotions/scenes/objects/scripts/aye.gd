extends CharacterBody2D

var emotions = 0

var emotion_scene = preload("res://games/emotions/scenes/objects/emotion.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(emotions):
		get_parent().add_child(emotion_scene.instantiate())

	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if dir.length():
		velocity = dir * 8 * 12
		if dir.x < 0: %AnimatedSprite2D.flip_h = true
		if dir.x > 0: %AnimatedSprite2D.flip_h = false
		%AnimatedSprite2D.play("walk")
		%AnimatedSprite2D.speed_scale = dir.length()
	else:
		velocity = Vector2.ZERO
		%AnimatedSprite2D.play("idle")
		%AnimatedSprite2D.speed_scale = 1

	move_and_slide()


func get_pill():
	emotions += 1
	await get_tree().create_timer(60).timeout
	emotions += -1
