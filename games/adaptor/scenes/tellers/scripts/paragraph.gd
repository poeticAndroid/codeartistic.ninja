extends Label

var story: Node
var line: String
var tree: TextTree

var _pressed: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("reveal")
	if story.get_classes(tree.line).has("center"):
		horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text = line
	await get_tree().create_timer(max(1, .08 * line.length())).timeout
	if story: story.step()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if not story: return
	if _pressed > Input.is_anything_pressed(): story.step()
	_pressed = Input.is_anything_pressed()
