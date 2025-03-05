extends Control

var story: Node
var line: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_teller(node: Node):
	add_child(node)


func close():
	pass
