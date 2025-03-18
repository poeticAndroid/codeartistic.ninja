extends Control

var story: Node
var line: String
var tree: TextTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if line.strip_edges() == "": line = "+"
	if line == "@": Global.reload_current_scene(true)
	elif line == "@<-": Global.go_back(true)
	elif line.begins_with("@->"): Global.goto_scene(line.substr(3), true)
	elif line.begins_with("@"): Global.replace_scene(line.substr(1), true)
	elif line == "$[]": Global.fadeout_music(); story.step()
	elif line == "^": story.endsub()
	elif line.ends_with(" ^"): story.gosub(line.left(-1).strip_edges())
	else: story.goto(line)
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
