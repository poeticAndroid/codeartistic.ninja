extends ScrollContainer

@export var story_file: TextResource
@export var passage: PackedScene
@export var tellers: Dictionary[String, PackedScene] = {}

var story: TextTree
var callstack: Array[TextTree] = []
var currentPassage: Node
var currentTeller: Node
var currentLine: TextTree
var nextLine: TextTree

var max_scroll: float = 0
var scroll_start: float = 0
var scroll_pos: float = 0
var scroll_target: float = 0
var scroll_accel: float = 100
var scroll_speed: float = 1

var IDs: Dictionary[String, TextTree] = {}
var _line_num: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var text = story_file.text
	story = TextTree.new()
	story.filename = story_file.resource_path
	_line_num = 0
	parse(story_file.text.split("\n"), story)
	nextLine = story.get_child(0)
	new_passage()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if max_scroll < get_v_scroll_bar().max_value - size.y:
		max_scroll = get_v_scroll_bar().max_value - size.y
		scroll_target = max_scroll
	if scroll_vertical < scroll_target:
		if (scroll_pos -scroll_start) < (scroll_target -scroll_pos):
			scroll_speed += scroll_accel * delta
		else:
			scroll_start = scroll_pos - scroll_target + scroll_pos
			scroll_speed -= scroll_accel * delta
		scroll_pos += abs(scroll_speed * delta)
		scroll_vertical = scroll_pos
	else:
		if scroll_speed:
			scroll_speed = 0
			if not is_instance_valid(currentTeller): return step()
			if not currentTeller.story: return step()
		scroll_start = scroll_vertical
		scroll_pos = scroll_vertical


func _input(event: InputEvent) -> void:
	if event is InputEventKey: scroll_target = 0
	if event is InputEventMouseButton: scroll_target = 0
	if event is InputEventScreenTouch: scroll_target = 0
	if event is InputEventJoypadButton: scroll_target = 0


func new_passage(line: String = ""):
	print("\n ---")
	if currentPassage:
		print()
		currentPassage.close()
	currentPassage = passage.instantiate()
	currentPassage.line = line
	%StoryContainer.add_child(currentPassage)


func step():
	if is_instance_valid(currentTeller) and currentTeller.story:
		currentTeller.story = null
		scroll_speed += 1
	if scroll_speed: return
	currentLine = nextLine
	if not currentLine:
		if callstack.size(): return endsub()
		else: return end()
	print(currentLine.line)
	currentLine.attributes.get_or_add("_visits", 0)
	currentLine.set_attribute("_visits", currentLine.get_attribute("_visits") + 1)
	var type = get_type(currentLine.line)
	if tellers.has(type):
		nextLine = currentLine.get_next_sibling()
		currentTeller = tellers[type].instantiate()
		currentTeller.story = self
		currentTeller.line = eval_line()
		currentTeller.tree = currentLine
		currentPassage.add_teller(currentTeller)
	else:
		nextLine = currentLine.get_child(0)
		call_deferred("step")


func goto(path: String):
	nextLine = find_line(path)
	step()


func gosub(path: String):
	callstack.push_back(nextLine)
	goto(path)


func endsub():
	nextLine = callstack.pop_back()
	step()


func end():
	print("THE END!")


func get_type(line: String) -> String:
	return line.get_slice(" ", 0).get_slice(".", 0).get_slice("#", 0).get_slice("(", 0)


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
		elif part.begins_with("#"):
			context = IDs[part.replace("#", "")]
		else:
			context = context.find("\n " + part + " ")
	return context


func eval_line(line = currentLine.line) -> String:
	var out: String = line.substr(line.find(" ")).get_slice("//", 0).strip_edges()
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
					print("$ ", JSON.stringify(out) + parts[i], " == ", result)
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
			IDs[last_child.line.get_slice(" ", 0).get_slice("#", 1).get_slice(".", 0).get_slice("(", 0).get_slice(" ", 0)] = last_child
		while _line_num < lines.size() and lines[_line_num].strip_edges() == "": _line_num += 1
