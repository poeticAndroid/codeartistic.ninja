class_name TextTree

var filename: String
var line_number: int = -1
var line: String = ""
var parent: TextTree = null
var attributes: Dictionary = {}
var children: Array[TextTree] = []


func add_new_child(line: String, line_number: int = -1):
	var child = TextTree.new()
	child.line = line.strip_edges()
	child.line_number = line_number
	return add_child(child)


func add_child(child: TextTree):
	return insert_child(child, children.size())


func insert_child(child: TextTree, index: int):
	child.remove()
	child.parent = self
	children.insert(index, child)
	return child


func remove_child(child: TextTree):
	children.erase(child)
	child.parent = null


func remove():
	if parent: parent.remove_child(self)



func get_parent():
	return parent


func get_root():
	if parent: return parent.get_root()
	return self


func get_child(i: int):
	if i >= 0 and i < children.size(): return children[i]
	return null


func get_child_index(child: TextTree):
	return children.find(child)


func get_previous_sibling():
	return get_sibling(-1)


func get_next_sibling():
	return get_sibling(1)


func get_sibling(delta: int):
	if parent: return parent.get_child(parent.get_child_index(self) + delta)
	return null


func find(substr: String):
	if ("\n " + line + " \n").contains(substr): return self
	for child in children:
		var r = child.find(substr)
		if r: return r
	return null



func get_filename():
	if filename: return filename
	if parent: return parent.get_filename()
	return null


func get_line_number():
	if line_number: return line_number
	if get_previous_sibling(): return get_previous_sibling().get_line_number()
	if parent: return parent.get_line_number()
	return null



func g(key: String): return get_attribute(key)
func s(key: String, val): return set_attribute(key, val)
func add(key: String, delta): return s(key, g(key) + delta)


func get_attributes(_result = {}):
	if parent: parent.get_attributes(_result)
	for key in attributes:
		_result[key] = attributes[key]
	return _result


func has_attribute(key: String):
	if attributes.has(key): return self
	if parent: return parent.has_attribute(key)
	return null


func get_attribute(key: String):
	if attributes.has(key): return attributes[key]
	if parent: return parent.get_attribute(key)
	return null


func set_attribute(key: String, val):
	if attributes.has(key): attributes[key] = val
	elif has_attribute(key): has_attribute(key).set_attribute(key, val)
	elif parent: parent.attributes[key] = val
	else: attributes[key] = val



func export_object() -> Dictionary:
	var out = {}
	if filename: out.filename = filename
	if line_number > -1: out.line_number = line_number
	if line: out.line = line
	var attr = JSON.stringify(attributes)
	if attr != "{}": out.attributes = JSON.parse_string(attr)
	if children:
		out.children = []
		for child in children:
			out.children.push_back(child.export_object())
	return out


func export_text(indentation: String = "\t") -> String:
	var out = line
	for child in children:
		if line:
			out += "\n" + child.export_text(indentation).indent(indentation)
		else:
			out += "\n" + child.export_text(indentation)
	return out
