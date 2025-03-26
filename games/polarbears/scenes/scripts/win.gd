extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.persistant.erase("polarbears_bestTime")
	var deaths = randi_range(100, 200)
	if Global.session.has("polarbears_recordings"):
		deaths = Global.session["polarbears_recordings"].size() - 1
	if deaths < Global.persistant.get_or_add("polarbears_bestDeaths", deaths):
		Global.persistant["polarbears_bestDeaths"] = deaths
		%NewRecord.visible = true
	%YouDied.text = "You died " + str(deaths) + " times."


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
