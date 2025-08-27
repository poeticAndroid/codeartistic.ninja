extends Area2D

var hover
var busy

const thoughts = [
		"Hmm.. still no likes..",
			"So much negativity..\nWhy are people so stupid..?",
			"Heh.. Cats are funny..",
			"That nigerian prince seems like a nice guy..",
			"First..!!1!",
			"Huh.. I guess it wasn't a dream..\nHe actually became president..",
			"I can haz life..?",
			"Did they ever find out what the fox said..?",
			"I can't believe he just tweeted that..",
			"Starving kids..? really..??\nRight in front of my salad..???",
			"I guess some people are just talented..",
			"Awww.. what a cute couple..",
			"I wish people would research before they share..\n..so I don't have to do it myself..",
			"I hate fidget spinners..",
			"I bet that video was totes fake..",
			"Politicians be cray cray..",
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not hover: return
	if Input.is_action_just_pressed("ui_accept"): activate()


func activate():
	if busy: return
	busy = true
	if Global.session.fine_food <= 0:
		get_parent().say("I should probably eat..")
		return
	if Global.session.fine_sleep <= 0:
		get_parent().say("I'm too sleepy to internet..")
		return
	%AnimatedSprite2D.play("active")
	get_parent().do("do", position.x)
	%Sfx.play()
	await wait(4)
	Global.session.fine_food -= 33
	Global.session.fine_sleep -= 34
	await get_parent().say(thoughts[randi_range(0, thoughts.size() - 1)])
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
