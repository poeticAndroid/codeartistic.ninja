extends CenterContainer

var entries = { }

var ws = WebSocketPeer.new()
var lastState
var outbox = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Tree.set_column_title(0, "Title")
	%Tree.set_column_title(1, "Users")
	if not %Tree.get_root():
		%Tree.create_item()
	%Tree.get_root().set_metadata(0, { dir = "blank" })
	%Tree.get_root().set_text(0, "The Empty Void")
	%Tree.get_root().set_text(1, "0 users")
	%Tree.get_root().set_text_alignment(1, HORIZONTAL_ALIGNMENT_RIGHT)

	apply_rooms(get_stored_rooms())

	print("Connecting to server...")
	ws.connect_to_url(NetConfig.servers[0])
	outbox = [{ type = "user", name = "Aye" }]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ws.poll()
	var state = ws.get_ready_state()

	while ws.get_available_packet_count():
		var msg = JSON.parse_string(ws.get_packet().get_string_from_utf8())
		print("Server: ", JSON.stringify(msg))
		match msg.type:
			"user":
				send({ type = "topic", key = NetConfig.get_key(msg) })

			"topic":
				apply_rooms(msg.rooms)

	if state == WebSocketPeer.STATE_OPEN:
		while outbox.size():
			ws.send_text(JSON.stringify(outbox.pop_front()))


func get_stored_rooms():
	var rooms = { }
	for _dir in DirAccess.get_directories_at("user://cost_of_creation"):
		if FileSystem.file_exists("user://cost_of_creation/" + _dir + "/room"):
			rooms[_dir] = FileSystem.get_file_as_json("user://cost_of_creation/" + _dir + "/room")
			rooms[_dir].users = { }
	return rooms


func apply_rooms(rooms):
	var _entries = { }
	for id in rooms.keys():
		var room = rooms[id]
		room.dir = id
		if not room.has("meta"): room.meta = { }
		if not room.meta.has("inheritance"): room.meta.inheritance = []
		if not room.meta.inheritance.has(room.id):
			room.meta.inheritance.push_back(room.id)
		room.path = "/".join(PackedStringArray(room.meta.inheritance))
		_entries[room.path] = id
	var paths = _entries.keys()
	paths.sort()
	for path in paths:
		var room = rooms[_entries[path]]
		if not entries.has(path):
			var inheritance = path.split("/")
			while inheritance.size() and not entries.has("/".join(inheritance)):
				inheritance.remove_at(inheritance.size() - 1)
			var parent = %Tree.get_root()
			if inheritance.size():
				parent = entries["/".join(inheritance)]
			entries[path] = parent.create_child()
		entries[path].set_metadata(0, room)
		entries[path].set_text(0, room.name)
		entries[path].set_text(1, str(room.users.size()) + " users")
		entries[path].set_text_alignment(1, HORIZONTAL_ALIGNMENT_RIGHT)


func send(msg):
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN: return
	outbox.push_back(msg)


func _on_play_btn_pressed() -> void:
	if not %Tree.get_selected(): return
	Global.session.room_id = %Tree.get_selected().get_metadata(0).dir
	if FileSystem.file_exists("user://cost_of_creation/" + Global.session.room_id + "/room"):
		var room = FileSystem.get_file_as_json("user://cost_of_creation/" + Global.session.room_id + "/room")
		room.id = %Tree.get_selected().get_metadata(0).id
		FileSystem.put_file_as_json("user://cost_of_creation/" + Global.session.room_id + "/room", room)
	Global.goto_scene("world")
