extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FileSystem.make_key()
	%WakeUpCall.request("https://hotater-eu.onrender.com/")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	Global.replace_scene("scenes/gallery", true)
