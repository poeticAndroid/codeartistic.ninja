extends CenterContainer

var story: Node
var line: String
var tree: TextTree

var _pressed: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("reveal")
	var img = line.get_slice(" ", 0)
	for node in get_children():
		if node is Control:
			node.visible = node.name.to_lower() == img.to_lower()
			node.tooltip_text = line.substr(line.find(" "))
	await get_tree().create_timer(2).timeout
	if story: story.step()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if not story: return
	if _pressed > Input.is_anything_pressed(): story.step()
	_pressed = Input.is_anything_pressed()
