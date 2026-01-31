extends CenterContainer

@export var button: Texture2D

var entries = { }

var ws = WebSocketPeer.new()
var lastState
var outbox = []

const BLANK_TITLE = "The Blank Page"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Tree.set_column_title(0, "Title")
	%Tree.set_column_expand_ratio(0, 256)
	%Tree.set_column_title(1, "Users")
	%Tree.set_column_expand_ratio(1, 64)
	%Tree.set_column_expand_ratio(2, 0)
	if not %Tree.get_root():
		%Tree.create_item()
	%Tree.get_root().set_metadata(0, { dir = "blank", name = BLANK_TITLE })
	%Tree.get_root().set_text(0, "Searching ...")
	%Tree.get_root().set_text(1, "0 users")
	%Tree.get_root().set_text_alignment(1, HORIZONTAL_ALIGNMENT_RIGHT)

	#%Status.text = "Looking for worlds online ..."
	ws.connect_to_url(NetConfig.servers[0])
	outbox = [{ type = "user", name = "Aye" }]

	await get_tree().create_timer(4).timeout
	if %Tree.get_root().get_text(0) != BLANK_TITLE:
		%Tree.get_root().set_text(0, BLANK_TITLE)
		apply_rooms(get_stored_rooms(), true)


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
				%Tree.get_root().set_text(0, BLANK_TITLE)
				apply_rooms(get_stored_rooms(), true)
				apply_rooms(msg.rooms, false)

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


func apply_rooms(rooms, deletable = false):
	var _entries = { }
	for id in rooms.keys():
		var room = rooms[id]
		room.dir = id
		if not room.has("meta"): room.meta = { }
		if not room.meta.has("history"): room.meta.history = [room.id]
		room.path = "/".join(PackedStringArray(room.meta.history))
		_entries[room.path] = id
	var paths = _entries.keys()
	paths.sort()
	for path in paths:
		var room = rooms[_entries[path]]
		if not entries.has(path):
			var history = path.split("/")
			while history.size() and not entries.has("/".join(history)):
				history.remove_at(history.size() - 1)
			var parent = %Tree.get_root()
			if history.size():
				parent = entries["/".join(history)]
				room.dir = parent.get_metadata(0).dir
			entries[path] = parent.create_child()
			if deletable:
				entries[path].add_button(2, button)
				entries[path].set_button_tooltip_text(2, 0, "Destroy this world!")
		entries[path].set_metadata(0, room)
		entries[path].set_text(0, room.name)
		if OS.is_debug_build():
			entries[path].set_tooltip_text(0, path.replace("/", "/\n") + "\n - " + room.dir)
		else:
			entries[path].set_tooltip_text(0, room.dir)
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


func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	var room = item.get_metadata(0)
	var confirm = ConfirmationDialog.new()
	confirm.dialog_text = "Are you sure you want to destroy\n" + room.name + " ?"
	add_child(confirm)
	confirm.popup_centered()
	print("just confirming ...")

	await confirm.confirmed

	print("Deleting ", room.dir, " ...")
	for _file in DirAccess.get_files_at("user://cost_of_creation/" + room.dir):
		DirAccess.remove_absolute("user://cost_of_creation/" + room.dir + "/" + _file)
	DirAccess.remove_absolute("user://cost_of_creation/" + room.dir)
	Global.reload_current_scene(false)


func _on_refresh_timer_timeout() -> void:
	Global.reload_current_scene(false)


func _on_idle_timer_timeout() -> void:
	Global.go_back()
