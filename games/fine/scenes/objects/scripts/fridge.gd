extends Area2D

var hover
var busy

const thoughts = [
		"I hope this doesn't make me fat..",
		"I wonder where I left my wallet..",
		"Armpits getting a bit smelly..",
		"Hmm.. when did I last clean this place..?",
		"I should really do the dishes...\neventually..",
		"Hmm.. which of these underpants are least smelly..?",
		"Hello Mr. Spider.. You owe me rent..",
		"Hmmmmm....",
		"Maybe I'll have a front door some day..",
		"Hmm.. low on milk..",
		"Okay..",
		"I don't like how the cheese is looking at me..",
		"Should I get a haircut..?\n..or hair..?",
		"Huh.. Weird..",
		"guess I'll add it to the shopping list..",
		"yum...",
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Global.session.has("fine_fridge"):
		Global.session.fine_fridge = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not hover: return
	if Input.is_action_just_pressed("ui_accept"): activate()


func activate():
	if busy: return
	busy = true
	if Global.session.fine_sleep <= -50:
		get_parent().say("I should probably go to sleep..")
		return
	%AnimatedSprite2D.play("active")
	get_parent().do("do", position.x)
	%Sfx.play()
	await wait(4)
	Global.session.fine_food = 100
	Global.session.fine_sleep -= 33
	await get_parent().say(thoughts[Global.session.fine_fridge])
	Global.session.fine_fridge = min(Global.session.fine_fridge + 1, thoughts.size() - 1)
	await wait(4)
	%Sfx.stop()
	get_parent().do("idle", position.x)
	%AnimatedSprite2D.play("idle")
	busy = false


func wait(sec = 1):
	return get_tree().create_timer(sec).timeout


func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D: return
	hover = true


func _on_body_exited(body: Node2D) -> void:
	hover = false
	busy = false
