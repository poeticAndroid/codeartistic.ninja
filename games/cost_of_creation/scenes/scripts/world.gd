extends Node2D

@onready var aye_scene = preload("res://games/cost_of_creation/scenes/objects/Aye.tscn")

var ws = WebSocketPeer.new()
var lastState
var reconnecting
var outbox = []

var user
var room
var cameraFollow
var lastPos = Vector2.ZERO
var lastMouseDown = Vector2.ZERO
var drawing = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Engine.max_fps = 12
	print("Connecting to server...")
	ws.connect_to_url(NetConfig.servers[0])
	outbox = [{ type = "user", name = "Aye" }]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var inp_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if inp_dir.length() > 0.5: cameraFollow = false
	%Camera.position += inp_dir * 128 * delta

	if user and user.has("node"):
		var dir = user.node.position - lastPos
		if cameraFollow: %Camera.position += dir + dir
		var b4 = %Camera.position
		%Camera.position = %Camera.position.clamp(
			user.node.position - Vector2(224, 78),
			user.node.position + Vector2(224, 78)
		)
		if b4 != %Camera.position: cameraFollow = true
		lastPos = user.node.position

	ws.poll()
	var state = ws.get_ready_state()

	while ws.get_available_packet_count():
		var msg = JSON.parse_string(ws.get_packet().get_string_from_utf8())
		print("Server: ", JSON.stringify(msg))
		match msg.type:
			"user":
				user = msg
				send({ type = "topic", key = NetConfig.get_key(user) })

			"topic":
				if msg.rooms.is_empty(): send({ type = "room", name = "Creation" })
				else: send({ type = "room", id = msg.rooms.keys()[0] })

			"room":
				if not room:
					room = msg
					send({ type = "obj", obj = "Aye", id = user.id, x = 0, y = 0 })
				for aye in room.users.values():
					if not aye.has("node"): continue
					if msg.users.has(aye.id):
						msg.users[aye.id].node = aye.node
					else:
						aye.node.leave()
				room = msg

			"obj":
				if msg.has("obj"):
					match msg.obj:
						"Aye":
							var aye = room.users[msg.from]
							if not aye.has("node"):
								aye.node = aye_scene.instantiate()
								add_child(aye.node)
							if msg.from == user.id:
								user.node = aye.node
							aye.node.goto(Vector2(msg.x, msg.y))

			"feedme":
				%CoinFeeder.request(msg.url)

			_:
				print("Don't know what to do with ", msg.type)

	match state:
		WebSocketPeer.STATE_CLOSED:
			print("Disconnected because ", ws.get_close_code(), " ", ws.get_close_reason())
			Global.go_back()
		WebSocketPeer.STATE_OPEN:
			while outbox.size():
				ws.send_text(JSON.stringify(outbox.pop_front()))


func _input(event: InputEvent) -> void:
	if not user: return
	if not user.has("node"): return

	var mouse_pos = Vector2.ZERO
	if event is InputEventMouse:
		mouse_pos = round(%Camera.position + event.position - Vector2(480, 270))

	if event is InputEventMouseButton:
		if event.button_mask:
			user.node.stop()
			lastMouseDown = mouse_pos
			drawing = false
		elif not drawing:
			send({ type = "obj", obj = "Aye", id = user.id,
				x = mouse_pos.x,
				y = mouse_pos.y })

	if event is InputEventMouseMotion:
		if (mouse_pos - lastMouseDown).length() > 8:
			drawing = true


func send(msg):
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN: return
	outbox.push_back(msg)
