extends Node2D

var advance_speed = -60
var time_left = 150
var player: Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 60
	TouchControls.engage(false)
	var recordings = Global.session.get_or_add("polarbears_recordings", [])
	var num = 0
	for recording in recordings:
		var inst = Protagonist.create(recording)
		inst.modulate = Color("#A0A0FF", 0.2 + ((num + 1) / (recordings.size() * 0.7)))
		%Protagonists.add_child(inst)
		num += 1
	recordings.push_back([])
	player = Protagonist.create(recordings.back(), true)
	%Protagonists.add_child(player)

	if Global.persistant.has("polarbears_bestTime"):
		%BestTime.text = "Best time: " + str(int(Global.persistant["polarbears_bestTime"]))
	%Deaths.text = "Deaths: " + str(recordings.size() - 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Camera2D.position.y += advance_speed / 60
	if $Camera2D.position.y <= 270:
		Global.replace_scene("win", true)
	time_left = floor(($Camera2D.position.y - 270) / 60)
	if not(is_instance_valid(player) and player.collision_layer):
		$Swirl.visible = true
		$Swirl.global_position = $Camera2D.global_position
		if Global.persistant.get_or_add("polarbears_bestTime", time_left) > time_left:
			Global.persistant["polarbears_bestTime"] = time_left

	%CountDown.text = "Countdown: " + str(int(time_left))


func add_bullet(node: Node):
	if node.get_parent():
		node.reparent(%Bullets)
	else:
		%Bullets.add_child(node)


func _on_area_2d_area_entered(area: Node) -> void:
	while area:
		if area.has_signal("on_screen"):
			area.emit_signal("on_screen")
			return
		area = area.get_parent()


func _on_area_2d_area_exited(area: Node) -> void:
	while area:
		if area.has_signal("off_screen"):
			area.emit_signal("off_screen")
			return
		area = area.get_parent()


func _on_kill_zone_area_entered(area: Node) -> void:
	while area:
		if area.scene_file_path:
			area.queue_free()
			return
		area = area.get_parent()


func _on_safe_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		area.collision_layer = 0
