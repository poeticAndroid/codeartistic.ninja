extends MarginContainer

var story: Node
var line: String

static var background: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if line.strip_edges():
		background = line
	for node in %Backgrounds.get_children():
		node.visible = node.name.to_lower() == background.to_lower()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	%Backgrounds.global_position = Vector2(480, 270)


func set_margin_top(margin: int):
	add_theme_constant_override("margin_top", margin)


func add_teller(node: Node):
	%StoryContainer.add_child(node)


func close():
	# await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	# tween.tween_property(%StoryContainer, "custom_minimum_size", %StoryContainer. get_minimum_size(), 5)
	tween.tween_property(%StoryContainer, "custom_minimum_size", Vector2.ZERO, 5)
	var tween2 = create_tween()
	tween2.set_trans(Tween.TRANS_QUAD)
	tween2.tween_method(set_margin_top, get_theme_constant("margin_top", ""), get_theme_constant("margin_bottom", ""), 5)
	# tween2.tween_property(style, "margin_top", style.margin_bottom, 1)
