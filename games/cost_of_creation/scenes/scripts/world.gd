extends Node2D

@onready var aye_scene = preload("res://games/cost_of_creation/scenes/objects/Aye.tscn")
@onready var puddle_scene = preload("res://games/cost_of_creation/scenes/objects/puddle.tscn")

var world_dir = "user://cost_of_creation/blank/"

var ws = WebSocketPeer.new()
var lastState
var outbox = []
var joined = false

var user = { type = "user", name = genrate_random_name().to_camel_case() }
var room = { type = "room", id = "auto", name = "The " + genrate_random_name().capitalize() }
var cameraFollow
var lastPos = Vector2.ZERO
var lastMouseDown = Vector2.ZERO
var drawing = false

var _img = Image.create_empty(960, 540, false, Image.FORMAT_RGBA8)
var _tile = Image.create_empty(256, 256, false, Image.FORMAT_RGBA8)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Engine.max_fps = 12
	if Global.persistant.has("creation_user"):
		user = Global.persistant.creation_user
	if Global.session.has("room_id"):
		room.id = Global.session.room_id
	world_dir = "user://cost_of_creation/" + room.id + "/"
	DirAccess.make_dir_recursive_absolute(world_dir)
	if FileSystem.file_exists(world_dir + "room"):
		room = FileSystem.get_file_as_json(world_dir + "room")
	print("Connecting to server...")
	ws.connect_to_url(NetConfig.servers[0])
	outbox = [user]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"): _on_idle_timer_timeout()
	var inp_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if inp_dir.length() > 0.5: cameraFollow = false
	%Camera.position += inp_dir * 128 * delta

	if user and user.has("node"):
		var dir = user.node.position - lastPos
		if cameraFollow: %Camera.position += dir + dir
		var b4 = %Camera.position.round()
		%Camera.position = %Camera.position.clamp(
			user.node.position - Vector2(224, 78),
			user.node.position + Vector2(224, 78)
		).round()
		if b4 != %Camera.position:
			cameraFollow = true
			if user.node.paused:
				user.node.goto(user.node.position + inp_dir * 64)
				send(user.node.to_obj())
		lastPos = user.node.position

	for tile in %Tiles.get_children():
		if tile.position.x < %Camera.position.x - 640:
			tile.goto(tile.col + 5, tile.row)
			refresh_puddles(tile.col, tile.row)
		if tile.position.x > %Camera.position.x + 640:
			tile.goto(tile.col - 5, tile.row)
			refresh_puddles(tile.col, tile.row)
		if tile.position.y < %Camera.position.y - 640:
			tile.goto(tile.col, tile.row + 5)
			refresh_puddles(tile.col, tile.row)
		if tile.position.y > %Camera.position.y + 640:
			tile.goto(tile.col, tile.row - 5)
			refresh_puddles(tile.col, tile.row)

	ws.poll()
	var state = ws.get_ready_state()

	while ws.get_available_packet_count():
		var msg = JSON.parse_string(ws.get_packet().get_string_from_utf8())
		#print("Server: ", JSON.stringify(msg))
		match msg.type:
			"user":
				user = msg
				Global.persistant.creation_user = JSON.parse_string(JSON.stringify(user))
				send({ type = "topic", key = NetConfig.get_key(user) })

			"topic":
				if room.has("id") and room.id == "auto":
					var best = 0
					if msg.rooms.is_empty():
						for _dir in DirAccess.get_directories_at("user://cost_of_creation/"):
							if FileSystem.file_exists("user://cost_of_creation/" + _dir + "/room"):
								var _room = FileSystem.get_file_as_json("user://cost_of_creation/" + _dir + "/room")
								if _room.has("meta") and _room.meta.has("inheritance") and best < _room.meta.inheritance.size():
									best = _room.meta.inheritance.size()
									world_dir = "user://cost_of_creation/" + _dir + "/"
									room = _room
					else:
						for _room in msg.rooms.values():
							if best < _room.users.keys().size():
								best = _room.users.keys().size()
								room = _room
				if room.has("id") and not msg.rooms.has(room.id):
					room.erase("id")
				send(room)

			"room":
				joined = msg
				if not world_dir.contains(msg.id):
					if DirAccess.dir_exists_absolute(world_dir):
						DirAccess.rename_absolute(world_dir, "user://cost_of_creation/" + msg.id)
					world_dir = "user://cost_of_creation/" + msg.id + "/"
					DirAccess.make_dir_recursive_absolute(world_dir)
					refresh_visible()
				FileSystem.put_file_as_json(world_dir + "room", msg)
				Global.session.room_id = msg.id
				if not user.has("node"):
					send({ type = "obj", obj = "Aye", id = "from", x = 0, y = 1 })
				if room.has("host") and room.host != msg.host:
					introduce("others")
				if msg.host == user.id:
					if not msg.has("meta"): msg.meta = { }
					if not msg.meta.has("inheritance"): msg.meta.inheritance = []
					if not msg.meta.inheritance.has(msg.id):
						msg.meta.inheritance.push_back(msg.id)
						send(msg)
				if room.has("users"):
					for aye in room.users.values():
						if not aye.has("node"): continue
						if msg.users.has(aye.id):
							msg.users[aye.id].node = aye.node
						else:
							aye.node.leave()
				room = msg
				%Title.text = room.name

			"obj":
				if msg.has("obj"):
					match msg.obj:
						"Aye":
							var aye = room.users[msg.from]
							if not aye.has("node"):
								aye.node = aye_scene.instantiate()
								aye.node.set_username(aye.name)
								%Players.add_child(aye.node)
								introduce(aye.id)
							if msg.from == user.id and not user.has("node"):
								user.node = aye.node
								%Canvas.aye = user.node
								user.node.connect("area_exited", _on_aye_area_exited)
								user.node.connect("pressed", _on_aye_pressed)
							if msg.has("x") and msg.has("y"):
								aye.node.goto(Vector2(msg.x, msg.y))
							if msg.has("spill"):
								aye.node.spill = msg.spill
							if msg.has("ink_fill"):
								aye.node.set_ink_fill(msg.ink_fill)
							if msg.has("h") and msg.has("s") and msg.has("l"):
								aye.node.set_ink_color(msg.h, msg.s, msg.l)
						"Canvas":
							apply_canvas(msg)
						"Tile":
							if msg.has("col") and msg.has("row") and msg.has("data"):
								FileSystem.put_file_as_bytes(world_dir + "tile_" + str(int(msg.col)) + "_" + str(int(msg.row)), msg.data.hex_decode())
								refresh_tile(msg.col, msg.row)
						"Puddle":
							FileSystem.put_file_as_json(world_dir + msg.id, msg)
							var node = %Puddles.get_node(msg.id)
							if msg.ink_fill and not node:
								node = puddle_scene.instantiate()
								node.name = msg.id
								%Puddles.add_child(node)
								node.connect("absorbed", _on_puddle_absorbed)
								if msg.has("x") and msg.has("y"):
									node.position = Vector2(msg.x, msg.y)
								else:
									node.set_ink_fill()
							if node:
								if msg.has("ink_fill"):
									node.set_ink_fill(msg.ink_fill)
								if msg.has("h") and msg.has("s") and msg.has("l"):
									node.set_ink_color(msg.h, msg.s, msg.l)

			"feedme":
				%CoinFeeder.request(msg.url)

			_:
				print("Don't know what to do with ", msg.type)

	if state == WebSocketPeer.STATE_OPEN:
		while outbox.size():
			ws.send_text(JSON.stringify(outbox.pop_front()))
	if lastState != state:
		if state == WebSocketPeer.STATE_CLOSED:
			print("Disconnected because ", ws.get_close_code(), " ", ws.get_close_reason())
			Global.go_back()
		lastState = state


func _input(event: InputEvent) -> void:
	if not user: return
	if not user.has("node"): return

	var mouse_pos = Vector2.ZERO
	if event is InputEventMouse:
		mouse_pos = round(%Camera.position + event.position - Vector2(480, 270))
		%IdleTimer.start()

	if event is InputEventMouseButton:
		Input.set_default_cursor_shape(Input.CURSOR_CROSS)
		if event.button_mask == 1:
			user.node.stop()
			%Canvas.position = %Camera.position
			%Canvas.clear()
			lastMouseDown = mouse_pos
			drawing = false
		elif not drawing:
			user.node.goto(mouse_pos)
		else:
			send(%Canvas.to_obj())
		if event.button_mask != 1:
			send(user.node.to_obj())

	if event is InputEventMouseMotion:
		if (mouse_pos - lastMouseDown).length() > 8:
			drawing = true
			if event.button_mask == 1:
				cameraFollow = false


func send(msg):
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN: return
	if msg.type == "obj" and not joined: return
	if msg.type == "msg" and not joined: return
	outbox.push_back(msg)


func introduce(user_id):
	await get_tree().create_timer(0.1).timeout
	if not user: return
	if not room: return
	if room.host != user.id: return
	if user_id == user.id: return
	print("Introducing ", user_id, " to the world...")

	var map_size = 1

	for file in DirAccess.get_files_at(world_dir):
		if file.begins_with("tile_") or file.begins_with("puddle_"):
			var parts = file.split("_")
			if parts[0] == "puddle" and parts.size() < 4: FileSystem.remove_absolute(world_dir + file)
			map_size = max(map_size, abs(parts[1].to_int()))
			map_size = max(map_size, abs(parts[2].to_int()))

	map_size *= 3
	var col = 0
	var row = 0

	await send_tile(col, row, user_id)
	var side = 1
	while side <= map_size:
		for i in range(0, side):
			col -= 1
			await send_tile(col, row, user_id)
		for i in range(0, side):
			row -= 1
			await send_tile(col, row, user_id)
		side += 1
		for i in range(0, side):
			col += 1
			await send_tile(col, row, user_id)
		for i in range(0, side):
			row += 1
			await send_tile(col, row, user_id)
		side += 1


func send_tile(col, row, user_id):
	var file = "tile_" + str(col) + "_" + str(row)
	var data = FileSystem.get_file_as_bytes(world_dir + file).hex_encode()

	#if OS.is_debug_build():
		#%IdleTimer.start()
		#send({ type = "obj", obj = "Aye", id = "from", x = col * 256 + 128, y = row * 256 + 128 })
		#await get_tree().create_timer(2).timeout
		#file = str(int(floor(col / 2.0))) + "_" + str(int(floor(row / 2.0))) + ".png"
		#_img.fill(Color.TRANSPARENT)
		##if FileAccess.file_exists(world_dir + file):
		#_img.load_png_from_buffer(FileAccess.get_file_as_bytes(world_dir + file))
		#data = _img.get_region(Rect2i(256 * abs(col % 2), 256 * abs(row % 2), 256, 256)).save_png_to_buffer().hex_encode()

	if data:
		await get_tree().create_timer(0.1).timeout
		send({ type = "obj", obj = "Tile", id = file, to = user_id, col = col, row = row, data = data })
	file = file.replace("tile_", "puddle_") + "_"
	for f in DirAccess.get_files_at(world_dir):
		if f.begins_with(file):
			var puddle = FileSystem.get_file_as_json(world_dir + f)
			puddle.to = user_id
			send(puddle)


func apply_canvas(msg):
	if not msg.has("png"): return
	if not msg.has("left"): return
	if not msg.has("top"): return
	_img.fill(Color.TRANSPARENT)
	_img.load_png_from_buffer(msg.png.hex_decode())

	for row in range(floor(msg.top / 256), ceil((msg.top + _img.get_size().y) / 256)):
		for col in range(floor(msg.left / 256), ceil((msg.left + _img.get_size().x) / 256)):
			var file = "tile_" + str(col) + "_" + str(row)
			_tile.fill(Color.TRANSPARENT)
			if FileSystem.file_exists(world_dir + file):
				_tile.load_png_from_buffer(FileSystem.get_file_as_bytes(world_dir + file))
			elif room.host == user.id and col % 2 and row % 2:
				send({ type = "obj", obj = "Puddle",
						id = file.replace("tile_", "puddle_") + "_" + str(Time.get_ticks_msec()),
						x = col * 256 + randi_range(0, 256), y = row * 256 + randi_range(0, 256),
						ink_fill = randi_range(1, 4), h = randi_range(0, 6) / 6.0, s = 1, l = randi_range(0, 2) / 2.0, })
			_tile.blend_rect(_img, _img.get_used_rect(), Vector2i(col * -256 + msg.left, row * -256 + msg.top))
			FileSystem.put_file_as_bytes(world_dir + file, _tile.save_png_to_buffer())
			refresh_tile(col, row)


func refresh_visible():
	for puddle in %Puddles.get_children():
		puddle.queue_free()
	await get_tree().create_timer(0.1).timeout
	for tile in %Tiles.get_children():
		tile.goto(tile.col, tile.row)
		refresh_puddles(tile.col, tile.row)


func refresh_tile(col, row):
	for tile in %Tiles.get_children():
		if tile.col == col and tile.row == row:
			tile.goto(tile.col, tile.row)


func refresh_puddles(col, row):
	var prefix = "puddle_" + str(col) + "_" + str(row) + "_"
	for file in DirAccess.get_files_at(world_dir):
		if file.begins_with(prefix):
			var puddle = FileSystem.get_file_as_json(world_dir + file)
			var node = %Puddles.get_node(puddle.id)
			if not node:
				node = puddle_scene.instantiate()
				node.name = puddle.id
				%Puddles.add_child(node)
				node.connect("absorbed", _on_puddle_absorbed)
			node.position.x = puddle.x
			node.position.y = puddle.y
			node.set_ink_fill(puddle.ink_fill)
			node.set_ink_color(puddle.h, puddle.s, puddle.l)


func genrate_random_name():
	var adjs = preload("res://games/blank/assets/adjs.txt").text.get_slice("  ", 0).strip_edges().split(" ")
	var nouns = preload("res://games/blank/assets/nouns.txt").text.get_slice("  ", 0).strip_edges().split(" ")
	return Array(adjs).pick_random() + "_" + Array(nouns).pick_random()


func _on_idle_timer_timeout() -> void:
	if user and user.has("node"):
		if user.node.in_puddle:
			send(user.node.in_puddle.to_obj())
		user.node.goto(Vector2.DOWN)
		send(user.node.to_obj())
	await get_tree().create_timer(0.25).timeout
	ws.close()


func _on_on_screen_area_entered(area: Area2D) -> void:
	if area.is_in_group("puddle"): area.staying = true


func _on_on_screen_area_exited(area: Area2D) -> void:
	if area.is_in_group("puddle"): area.queue_free()


func _on_aye_area_exited(area: Area2D) -> void:
	if area.is_in_group("puddle"):
		send(area.to_obj())


func _on_aye_pressed():
	user.node.paused = true
	user.node.target = user.node.position
	user.node.spill = not user.node.spill
	user.node.ink_fill -= 0.015625
	send(user.node.to_obj())
	if user.node.in_puddle:
		user.node.in_puddle.ink_fill += 0.015625
	else:
		var id = "puddle_" + str(int(floor(user.node.position.x / 256))) + \
				"_" + str(int(floor(user.node.position.y / 256))) + \
				"_" + str(Time.get_ticks_msec())
		send({
			type = "obj", obj = "Puddle", id = id,
			x = user.node.position.x, y = user.node.position.y,
			ink_fill = 0.015625,
			h = user.node.ink_color.hue,
			s = user.node.ink_color.saturation,
			l = user.node.ink_color.lightness,
		})
	drawing = true


func _on_puddle_absorbed(puddle):
	if puddle.in_puddle:
		send(puddle.in_puddle.to_obj())
	send(puddle.to_obj())
