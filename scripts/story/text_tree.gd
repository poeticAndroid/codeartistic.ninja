class_name TextTree

var filename: String
var line_number: int = -1
var line: String = ""
var parent: TextTree = null
var attributes: Dictionary = { }
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

#
# navigation


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

#
# get source


func get_filename():
	if filename: return filename
	if parent: return parent.get_filename()
	return null


func get_line_number():
	if line_number: return line_number
	if get_previous_sibling(): return get_previous_sibling().get_line_number()
	if parent: return parent.get_line_number()
	return null

#
# attributes




func g(key: String): return get_attribute(key)
func s(key: String, val): return set_attribute(key, val)
func add(key: String, delta): return s(key, g(key) + delta)


func get_attributes(_result = { }):
	if parent: parent.get_attributes(_result)
	for key in attributes:
		_result[key] = attributes[key]
	return _result


func has_attribute(key: String):
	key = key.to_lower()
	if attributes.has(key): return self
	if parent: return parent.has_attribute(key)
	return null


func get_attribute(key: String):
	var cap = key.substr(0, 1) != key.substr(0, 1).to_lower()
	if attributes.has(key.to_lower()):
		key = key.to_lower()
		if attributes[key] is not String: cap = false
		return attributes[key].substr(0, 1).to_upper() + attributes[key].substr(1) if cap else attributes[key]
	if parent: return parent.get_attribute(key)
	return null


func set_attribute(key: String, val):
	key = key.to_lower()
	if attributes.has(key): attributes[key] = val
	elif has_attribute(key): has_attribute(key).set_attribute(key, val)
	elif parent: parent.attributes[key] = val
	else: attributes[key] = val

#
# Expression helpers


func if_else(cond, iftrue, iffalse = ""):
	return iftrue if cond else iffalse


func push_to_cols(cols, count = 3):
	for i in range(1, count + 1):
		for col in cols:
			if not g(col + str(i)).begins_with("%"):
				g(col + "s").push_back(g(col + str(i)))
				# s(col + "s") = g(col + "s")
				s(col + str(i), "%" + col + str(i))


func shear_cols(cols):
	for j in range(cols.size()):
		var col = g(cols[j] + "s")
		for i in range(1, j + 1):
			if col.size(): col.push_back(col.pop_front())


func shuffle_cols(cols):
	for col in cols:
		g(col + "s").shuffle()

#
# Exporting


func export_object() -> Dictionary:
	var out = { }
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
