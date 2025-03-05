extends Label

signal step

var line: String
var tree: TextTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = line
	await get_tree().create_timer(max(1, .08 * line.length())).timeout
	emit_signal("step")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# custom_minimum_size.y += -1
	pass
