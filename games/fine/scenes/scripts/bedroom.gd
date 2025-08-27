extends Node2D

var busy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 12
	if not Global.session.has("fine_sleep"):
		Global.session.fine_sleep = 100
		Global.session.fine_food = 100
	%Bed.wake_up()
	if Global.session.fine_wisdom < 2:
		await get_tree().create_timer(3).timeout
		await say("What a weird dream..")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func say(msg):
	return %Dialog.say(msg)


func do(state, x):
	busy = state != "idle"
	%Aye.position.x = x
	%Aye.do(state)
