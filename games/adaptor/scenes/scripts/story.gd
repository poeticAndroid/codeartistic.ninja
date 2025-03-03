extends Control

@export var story_file: TextResource

var story: TextTree
var callstack: Array[TextTree] = []

var _line_num: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var text = story_file.text
	$VBoxContainer/RichTextLabel.text = text
	story = TextTree.new()
	story.filename = story_file.resource_path
	_line_num = 0
	parse(story_file.text.split("\n"), story)
	print(story.export_text(" "))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func parse(lines: Array[String], parent: TextTree):
	if not lines.size(): return
	while _line_num < lines.size() and lines[_line_num].strip_edges() == "": _line_num += 1
	var line = lines[_line_num]
	var indent = line.substr(0, line.find(line.strip_edges()))
	var last_child = parent
	while _line_num < lines.size() and lines[_line_num].begins_with(indent):
		line = lines[_line_num].substr(indent.length())
		if line.substr(0, 1).strip_edges() == "":
			parse(lines, last_child)
		else:
			_line_num += 1
			last_child = parent.add_new_child(line, _line_num)
		while _line_num < lines.size() and lines[_line_num].strip_edges() == "": _line_num += 1
