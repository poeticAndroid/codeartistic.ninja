extends Area2D

var hover
var busy = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not hover: return
	if Input.is_action_just_pressed("ui_accept"): activate()


func activate():
	if busy: return
	busy = true
	if Global.session.fine_food <= 0:
		get_parent().say("I'm too hungry to sleep..")
		return
	if Global.session.fine_sleep > 0:
		get_parent().say("I'm not really sleepy right now..")
		return
	get_parent().do("sleep", position.x)
	Global.session.fine_wisdom += 1
	await wait(4)
	Global.session.fine_food -= 66
	Global.session.fine_sleep = 100
	Global.replace_scene("dream", true)


func wake_up():
	await wait(2)
	get_parent().do("idle", position.x)
	busy = false


func wait(sec = 1):
	return get_tree().create_timer(sec).timeout


func _on_body_entered(body: Node2D) -> void:
	hover = true


func _on_body_exited(body: Node2D) -> void:
	hover = false
	busy = false
