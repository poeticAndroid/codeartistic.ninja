extends CharacterBody2D

@export var dark = true
@export var state = "idle"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if dark:
		%AnimatedSprite2D.sprite_frames = preload("res://games/fine/assets/sprites/dark_aye.tres")
	else:
		%AnimatedSprite2D.sprite_frames = preload("res://games/fine/assets/sprites/aye.tres")
	%AnimatedSprite2D.play(state)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == "do" or state == "sleep": return
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


func do(s = "do"):
	state = s
	velocity = Vector2.ZERO
	if state == "sleep": %AnimatedSprite2D.flip_h = false
	%AnimatedSprite2D.play(state)
	%AnimatedSprite2D.speed_scale = 1
