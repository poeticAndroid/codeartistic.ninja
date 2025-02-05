@tool
extends Control

@export var game_cover: Texture2D:
	set(_game_cover):
		game_cover = _game_cover
		%Button.icon = game_cover
@export var game_title: String:
	set(_game_title):
		game_title = _game_title
		%Button.text = game_title
@export var game_name: String
@export var game_description: String:
	set(_game_description):
		game_description = _game_description
		%Button.tooltip_text = game_description
@export var wip: bool:
	set(_wip):
		wip = _wip
		if wip: modulate.a = 0.25
		else: modulate = Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var btn: Button = %Button
	if Engine.is_editor_hint(): return
	await get_tree().create_timer(.8).timeout

	btn.rotation = randf_range(-PI / 90, PI / 90)
	if Global.session.has("last_game"):
		if Global.session["last_game"] == game_name: grab_focus()
	else:
		Global.session["last_game"] = game_name
		grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	print("Starting game ", game_name)
	Global.session["last_game"] = game_name
	Global.goto_scene("/games/" + game_name + "/start")


func _on_focus_entered() -> void:
	%Button.grab_focus()
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(%Button, "rotation", randf_range(-PI / 90, PI / 90), 1)
	tween.tween_property(%Button, "scale", Vector2(1.1, 1.1), 1)


func _on_focus_exited() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(%Button, "scale", Vector2.ONE, 1)
