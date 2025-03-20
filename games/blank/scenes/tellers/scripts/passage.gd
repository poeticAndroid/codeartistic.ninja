extends PanelContainer

var story: Node
var line: String

@export var closed_margin = 8


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
	# tween2.tween_property(style, "margin_top", style.margin_bottom, 1)
