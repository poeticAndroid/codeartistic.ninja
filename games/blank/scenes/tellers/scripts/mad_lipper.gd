extends RichTextLabel

var story: Node
var line: String
var tree: TextTree

var input_name
var output = ""
var input_choices


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if story.get_classes(tree.line).has("center"):
		horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	set_output("")
	$TextEdit.grab_focus()
	if not line.strip_edges(): story.step()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func type():
	print("typing")
	if input_name:
		if $TextEdit.text.strip_edges(): $TypewriterSfx.play()
		if $TextEdit.text.ends_with("\n"): set_first_name()
		if $TextEdit.text.ends_with("\t"): set_first_name()
		else: set_output()
	else:
		var p = output.length() + 1
		set_output(line.substr(0, p))
		if line.substr(p, 1) == "%" or output.contains("%"):
			$TypewriterSfx.stop()
			$StopSfx.play()
			get_first_name()
		elif line.substr(p - 1, 1) != " " and line.strip_edges() != output.strip_edges():
			$TypewriterSfx.play()
			await get_tree().create_timer(randf_range(0.03, 0.08)).timeout
			type()
		else:
			$TextEdit.text = " "
	if not story: return
	set_status()


func get_first_name():
	var p = line.find("%")
	var name = ""
	var char = ""
	if p < 0: return ""
	set_output(line.substr(0, p))
	name = line.substr(p, 1)
	input_name = ""
	p += 1
	while p < line.length():
		char = line.substr(p, 1)
		p += 1
		if ("x" + char).is_valid_ascii_identifier() and char != "_":
			input_name += char
			name += char
		elif ";$".contains(char):
			name += char
		else:
			p = line.length()
	var desc = tree.get_attribute(input_name + "_")
	if desc is Array:
		input_choices = desc
	elif name.ends_with("Xe"):
		input_choices = ["he", "she", "it", "they"]
	elif name.ends_with("Xim"):
		input_choices = ["him", "her", "it", "them"]
	elif name.ends_with("Xis"):
		input_choices = ["his", "her", "its", "their"]
	$TextEdit.text = ""
	print("reading ", name)
	return name


func set_first_name():
	var val = $TextEdit.text.strip_edges().replace("%", "")
	if not val:
		output = output.strip_edges()
		return
	var name = get_first_name()
	if input_choices:
		val = val.to_lower()
		if not input_choices.has(val):
			return set_output(output.substr(0, line.find("%")))
		if name.ends_with("Xe") or name.ends_with("Xim") or name.ends_with("Xis"):
			var gender = input_choices.find(val)
			var suf = get_suffix(name)
			tree.set_attribute(input_name.replace(suf, "Xe"), ["he", "she", "it", "they"][gender])
			tree.set_attribute(input_name.replace(suf, "Xim"), ["him", "her", "it", "them"][gender])
			tree.set_attribute(input_name.replace(suf, "Xis"), ["his", "her", "its", "their"][gender])
	tree.set_attribute(input_name, val)
	line = story.eval_line(tree.line)
	input_name = null
	input_choices = null
	set_output(output + " " + val + " ")


func set_output(txt = output):
	output = txt
	text = output
	if input_name: text += " " + $TextEdit.text
	while text.contains("  "): text = text.replace("  ", " ")
	if output.length() < line.length():
		text += '[bgcolor=#777][font_size=1]|'
		$TextEdit.grab_focus()
	elif story:
		$TypewriterSfx.stop()
		$EnterSfx.play()
		story.step()


func set_status(status = ""):
	if not status:
		if input_name:
			if output.ends_with("%"):
				status = "Press backspace and type in "
			else:
				status += "Type in "
			if input_choices:
				status += "/".join(input_choices)
			else:
				if tree.get_attribute(input_name + "_"):
					status += tree.get_attribute(input_name + "_")
				else:
					if get_suffix(input_name):
						status += get_suffix(input_name).to_lower()
					else:
						status += "something"
			if output.ends_with("%"):
				status += ", then press enter."
			else:
				status += "."
		else:
			if line.substr(output.length(), 1) == "%":
				status = "Press enter."
			else:
				status = "Type anything."
	if story: story.set_status(status)


func get_suffix(name: String):
	var suf = ""
	while name:
		suf = name.substr(name.length() - 1) + suf
		name = name.substr(0, name.length() - 1)
		if suf.substr(0, 1) != suf.substr(0, 1).to_lower():
			return suf
	return null


func _input(event: InputEvent) -> void:
	if not story:
		if is_instance_valid($TextEdit): $TextEdit.queue_free()
		return
	$TextEdit.grab_click_focus()
	$TextEdit.grab_focus()
	if not event is InputEventKey: return
	if not event.is_pressed(): return
	call_deferred("type")
