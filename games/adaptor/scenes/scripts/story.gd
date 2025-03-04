extends Control

@export var story_file: TextResource
@export var tellers: Dictionary[String, PackedScene] = {}

var story: TextTree
var callstack: Array[TextTree] = []
var currentTeller: Node
var currentLine: TextTree
var nextLine: TextTree

var _line_num: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var text = story_file.text
	story = TextTree.new()
	story.filename = story_file.resource_path
	_line_num = 0
	parse(story_file.text.split("\n"), story)
	nextLine = story.get_child(0)
	step()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func step():
	disconnect_teller()
	currentLine = nextLine
	if not currentLine:
		if callstack.size(): return endsub()
		else: return end()
	currentLine.attributes.get_or_add("_visits", 0)
	currentLine.set_attribute("_visits", currentLine.get_attribute("_visits") + 1)
	var type = get_type(currentLine.line)
	if tellers.has(type):
		nextLine = currentLine.get_next_sibling()
		currentTeller = tellers[type].instantiate()
		currentTeller.line = eval_line()
		currentTeller.tree = currentLine
		currentTeller.connect("step", step)
		currentTeller.connect("goto", goto)
		currentTeller.connect("gosub", gosub)
		currentTeller.connect("endsub", endsub)
		%StoryContainer.add_child(currentTeller)
	else:
		nextLine = currentLine.get_child(0)
		call_deferred("step")


func goto(path: String):
	disconnect_teller()
	nextLine = find_line(path)
	step()


func gosub(path: String):
	callstack.push_back(nextLine)
	goto(path)


func endsub():
	disconnect_teller()
	nextLine = callstack.pop_back()
	step()


func end():
	disconnect_teller()
	print("THE END!")


func disconnect_teller(node: Node = currentTeller):
	if not node: return
	node.disconnect("step", step)
	node.disconnect("goto", goto)
	node.disconnect("gosub", gosub)
	node.disconnect("endsub", endsub)


func get_type(line: String) -> String:
	return line.get_slice(" ", 0).get_slice(".", 0).get_slice("#", 0)


func find_line(path: String, context = currentLine):
	var parts = path.split(" ", false)
	for part in parts:
		if part.begins_with("#"): context = story
		if part.contains(".+"):
			for i in range(0, part.length()):
				if part.substr(i, 1) == ".": context = context.get_parent()
				if part.substr(i, 1) == "+": context = context.get_next_sibling()
		elif part == "..":
			context = context.get_parent()
		elif part == "0":
			context = context.get_child(0)
		elif part == "+":
			context = context.get_next_sibling()
		elif part == "-":
			context = context.get_previous_sibling()
		else:
			context = context.find(part + " ")
	return context


func eval_line(line = currentLine.line) -> String:
	var out: String = line.substr(line.find(" ")).strip_edges()
	var p1: int = 0
	var p2: int = 0
	p1 = out.find("{")
	while p1 >= 0:
		p1 += 1
		p2 = out.find("}", p1)
		var tag = out.substr(p1, p2 -p1)
		out = out.left(p1 -1) + smart_tag(tag) + out.right(-1 - p2)
		p1 = out.find("{", p2)
	return out.strip_edges()


func smart_tag(tag: String) -> String:
	var out = tag
	var parts = tag.split("|")
	if parts[0].begins_with("$"):
		var key = parts[0].substr(1)
		out = currentLine.get_attribute(key)
		if parts.size() == 2:
			out = ""
			if parts[1].begins_with("+"):
				currentLine.set_attribute(key, currentLine.get_attribute(key) + lazyJson(parts[1].substr(1)))
			else:
				currentLine.set_attribute(key, lazyJson(parts[1]))
		elif parts.size() > 2:
			var expr = Expression.new()
			for i in range(1, parts.size(), 2):
				if i < parts.size()-1:
					var error = expr.parse(JSON.stringify(out) + parts[i])
					if error != OK:
						out = "{" + expr.get_error_text() + "}"
						break
					var result = expr.execute()
					if expr.has_execute_failed():
						out = "{" + expr.get_error_text() + "}"
						break
					if result:
						out = parts[i + 1]
						break
				else:
					out = parts[i]
	elif parts[0].begins_with("~"):
		parts = tag.substr(1).split("|")
		out = parts[randi_range(0, parts.size()-1)]
	elif parts[0].begins_with("@"):
		parts = tag.substr(1).split("|")
		out = parts[(int(currentLine.get_attribute("_visits"))-1) % parts.size()]
	else:
		out = parts[min((int(currentLine.get_attribute("_visits"))-1), parts.size()-1)]
	return out


func lazyJson(str: String):
	if str.strip_edges() == "null": return null
	var out = JSON.parse_string(str)
	if out == null: return str
	return out


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
