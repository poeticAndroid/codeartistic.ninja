extends RichTextLabel

var dict = " an the of to  ATOSCPIBFWMHRDELGNUVJKYQZX eationrslhcdumpgfybwvkxzjq"
static var dicts = {
		adj = preload("res://games/blank/assets/adjs.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/verbs.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/nouns.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/names.txt").text.get_slice("  ", 0) +
			"  " + preload("res://games/blank/assets/adjs.txt").text.get_slice("  ", 1),
		verb = preload("res://games/blank/assets/verbs.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/adjs.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/nouns.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/names.txt").text.get_slice("  ", 0) +
			"  " + preload("res://games/blank/assets/verbs.txt").text.get_slice("  ", 1),
		noun = preload("res://games/blank/assets/nouns.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/names.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/verbs.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/adjs.txt").text.get_slice("  ", 0) +
			"  " + preload("res://games/blank/assets/nouns.txt").text.get_slice("  ", 1),
		name = preload("res://games/blank/assets/names.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/nouns.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/verbs.txt").text.get_slice("  ", 0) +
			preload("res://games/blank/assets/adjs.txt").text.get_slice("  ", 0) +
			"  " + preload("res://games/blank/assets/names.txt").text.get_slice("  ", 1),
	}
static var categories = {
		hobby = "verb",
		relation = "noun",
		place = "name",
		inhabitant = "noun",
		number = "adj",
		media = "noun"
	}

var story: Node
var line: String
var tree: TextTree

var input_name
var output = ""
var input_choices

var next_char: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if story.get_classes(tree.line).has("center"):
		horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	set_output("")
	$TextEdit.grab_focus()
	next_char = predict_next_char(" ")
	if not line.strip_edges():
		if is_instance_valid($TextEdit): $TextEdit.queue_free()
		if story: story.step()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func type():
	if not is_instance_valid($TextEdit): return
	if input_name:
		if not $TextEdit.text.strip_edges(): $TextEdit.text = " "
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
			await get_tree().create_timer(randf_range(0.03, 0.08)).timeout
			call_deferred("type")
		else:
			$TextEdit.text = " "
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
	if name.substr(0, 1) != name.substr(0, 1).to_lower():
		val = val.substr(0, 1).to_upper() + val.substr(1)
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
	var len_b4 = text.length()
	output = txt
	text = output
	if input_name: text += " " + $TextEdit.text
	text = text.replace("\n", " ").replace("\t", " ")
	while text.contains("  "): text = text.replace("  ", " ")
	if output.length() < line.length():
		text += '[img]uid://dydc7aycyobo3[/img]'
		if len_b4 != text.length():
			$TypewriterSfx.play()
		$TextEdit.grab_focus()
	else:
		$EnterSfx.play()
		if is_instance_valid($TextEdit): $TextEdit.queue_free()
		if story: story.step()


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
	for cat in categories:
		if status.containsn(cat): dict = dicts[categories[cat]]
	for cat in dicts:
		if status.containsn(cat): dict = dicts[cat]
	if story: story.set_status(status)


func get_suffix(name: String):
	var suf = ""
	while name:
		suf = name.substr(name.length() - 1) + suf
		name = name.substr(0, name.length() - 1)
		if suf.substr(0, 1) != suf.substr(0, 1).to_lower():
			return suf
	return null


func is_dpad_pressed():
	return \
		Input.is_action_pressed("ui_up") or \
		Input.is_action_pressed("ui_down") or \
		Input.is_action_pressed("ui_left") or \
		Input.is_action_pressed("ui_right") or \
		Input.is_action_pressed("ui_accept")


func predict_next_char(word: String):
	word = word.substr(word.rfind(" ")).to_lower()
	if not word.strip_edges(): return " " + dict.substr(dict.rfind("  ") + 2).to_lower().get_slice(" ", 0) + " "
	var next_char = ""
	var p: int
	while word and next_char.length() < 26:
		p = dict.find(word)
		while p > -1:
			p += word.length()
			if not next_char.contains(dict.substr(p, 1)): next_char += dict.substr(p, 1).strip_edges()
			p = dict.find(word, p)
		word = word.substr(1)
	p = dict.rfind(" ")
	while p < dict.length():
		if not next_char.contains(dict.substr(p, 1)): next_char += dict.substr(p, 1).strip_edges()
		p += 1
	return " " + next_char + " "


func _input(event: InputEvent) -> void:
	if not story: return
	$TextEdit.grab_click_focus()
	$TextEdit.grab_focus()
	$TextEdit.set_caret_line($TextEdit.text.length())
	$TextEdit.set_caret_column($TextEdit.text.length())

	if Global.input_method != Global.DESKTOP_INPUT: return _on_game_key_timer_timeout()
	if not event is InputEventKey: return
	if event.physical_keycode == KEY_BACKSPACE: event.unicode = 8
	if event.physical_keycode == KEY_TAB: event.unicode = 9
	if event.physical_keycode == KEY_ENTER: event.unicode = 10
	if not event.unicode: return _on_game_key_timer_timeout()
	if not event.is_pressed(): return
	call_deferred("type")


func _on_game_key_timer_timeout() -> void:
	if not story: return
	var idle_wait = 0.5
	var pressed = is_dpad_pressed()
	if pressed and not $GameKeyTimer.is_stopped(): return
	$GameKeyTimer.stop()
	$GameKeyTimer.wait_time *= 0.8

	if not $TextEdit.text.begins_with(" "): $TextEdit.text = " " + $TextEdit.text
	var char = $TextEdit.text.right(1)
	var char_pos = next_char.find(char)
	if Input.is_action_pressed("ui_up"): char_pos = next_char.rfind(char)
	if input_choices: char_pos = input_choices.find($TextEdit.text.strip_edges())

	if Input.is_action_pressed("ui_left"):
		$TextEdit.text = $TextEdit.text.left(-1)
		next_char = predict_next_char($TextEdit.text.left(-1))
	if Input.is_action_pressed("ui_right"):
		next_char = predict_next_char($TextEdit.text)
		$TextEdit.text += next_char.strip_edges().left(1)
	if Input.is_action_pressed("ui_down"):
		char_pos += 1
	if Input.is_action_pressed("ui_up"):
		char_pos += -1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_up"):
		if input_choices:
			if char_pos >= input_choices.size(): char_pos = 0
			if char_pos < 0: char_pos = input_choices.size() - 1
			$TextEdit.text = input_choices[char_pos]
		else:
			$TextEdit.text = $TextEdit.text.left(-1) + next_char.substr(char_pos, 1)
	if Input.is_action_pressed("ui_accept"):
		next_char = predict_next_char(" ")
		$TextEdit.text += "\n"

	if pressed:
		$GameKeyTimer.start()
		call_deferred("type")
	else:
		$GameKeyTimer.wait_time = idle_wait


static var _tried = ["yes"]
static var _id = 0
var _shown = 10
func _on_test_timer_timeout() -> void:
	if Input.is_action_pressed("ui_select") or not story:
		$TestTimer.one_shot = true
		return
	var action = "ui_accept"
	if input_choices:
		if _tried.has($TextEdit.text.strip_edges()):
			action = "ui_down"
		else:
			_tried.push_back($TextEdit.text.strip_edges())
		if _shown:
			_shown += -1
		else:
			_tried.pop_front()
	elif input_name:
		_id += 1
		$TextEdit.text = " e&" + input_name + "-" + str(_id) + "; "
	var event = InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().create_timer(0.1).timeout
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)
	Global.input_method = Global.GAMEPAD_INPUT
