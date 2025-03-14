extends MarginContainer

var story: Node
var line: String

@export var closed_margin = 8

static var background: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if line.strip_edges():
		background = line
		story.wait_for_scroll = true
	for node in %Backgrounds.get_children():
		node.visible = node.name.to_lower() == background.to_lower()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%Backgrounds.global_position = Vector2(480, 270)


func _draw() -> void:
	%Backgrounds.global_position = Vector2(480, 270)


func set_margin_top(margin: int):
	add_theme_constant_override("margin_top", margin)


func set_margin_bottom(margin: int):
	add_theme_constant_override("margin_bottom", margin)


func add_teller(node: Node):
	%StoryContainer.add_child(node)


func close():
	# await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	# tween.tween_property(%StoryContainer, "custom_minimum_size", %StoryContainer. get_minimum_size(), 5)
	tween.set_parallel()
	tween.tween_property(self, "custom_minimum_size", Vector2.ZERO, 5)
	tween.tween_property(%StoryContainer, "custom_minimum_size", Vector2.ZERO, 5)
	var tween2 = create_tween()
	tween2.set_trans(Tween.TRANS_QUAD).set_parallel()
	tween2.tween_method(set_margin_top, get_theme_constant("margin_top", ""), closed_margin, 5)
	tween2.tween_method(set_margin_bottom, get_theme_constant("margin_bottom", ""), closed_margin, 5)
	# tween2.tween_property(style, "margin_top", style.margin_bottom, 1)
