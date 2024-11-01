extends Control

var active_link: LinkButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_works_link_pressed()
	await get_tree().create_timer(1).timeout
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	var foc = get_tree().root.gui_get_focus_owner()
	if foc:
		tween.tween_property(%ScrollContainer, "scroll_vertical", %ScrollContainer.scroll_vertical + foc.global_position.y - 256, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func hi_link(node: LinkButton):
	if active_link:
		active_link.underline = LinkButton.UNDERLINE_MODE_ON_HOVER
		active_link.add_theme_color_override("font_color", Color("#acf"))
		active_link.add_theme_color_override("font_hover_color", Color("#acf"))
	active_link = node
	active_link.underline = LinkButton.UNDERLINE_MODE_ALWAYS
	active_link.add_theme_color_override("font_color", Color("#ff9"))
	active_link.add_theme_color_override("font_hover_color", Color("#ff9"))


func _input(event: InputEvent) -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	if Input.is_action_just_pressed("ui_up"):
		tween.tween_property(%ScrollContainer, "scroll_vertical", %ScrollContainer.scroll_vertical - 200, 1)
	if Input.is_action_just_pressed("ui_down"):
		tween.tween_property(%ScrollContainer, "scroll_vertical", %ScrollContainer.scroll_vertical + 200, 1)


func _on_works_link_pressed() -> void:
	%Heading.text = "Interactive works of art"
	%ManifestoTxt.visible = false
	%GamesContainer.visible = true
	hi_link(%WorksLink)


func _on_manifesto_link_pressed() -> void:
	%Heading.text = "The Codeartistic Manifesto"
	%GamesContainer.visible = false
	%ManifestoTxt.visible = true
	hi_link(%ManifestoLink)
