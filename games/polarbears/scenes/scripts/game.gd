extends Node2D

var advance_speed = -60
var time_left = 150

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 60
	if Global.persistant.has("polarbears_bestTime"):
		%BestTime.text = "Best time: " + str(Global.persistant["polarbears_bestTime"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Camera2D.position.y += advance_speed / 60
	if $Camera2D.position.y <= 270:
		Global.replace_scene("win", true)
	time_left = floor(($Camera2D.position.y - 270) / 60)
	if Global.persistant.get_or_add("polarbears_bestTime", 160) > time_left:
		Global.persistant["polarbears_bestTime"] = time_left

	%CountDown.text = "Countdown: " + str(time_left)
