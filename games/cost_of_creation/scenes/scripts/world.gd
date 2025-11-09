extends Node2D

@onready var aye_scene = preload("res://games/cost_of_creation/scenes/objects/Aye.tscn")

var ws = WebSocketPeer.new()
var lastState
var reconnecting
var outbox = []

var user
var room
var lastPos = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Engine.max_fps = 12
	print("Connecting to server...")
	ws.connect_to_url(NetConfig.servers[0])
	outbox = [{ type = "user", name = "Aye" }]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if user and user.has("node"):
		var dir = user.node.position - lastPos
		%Camera.position += dir + dir
		%Camera.position = %Camera.position.clamp(
			user.node.position - Vector2(224, 78),
			user.node.position + Vector2(224, 78)
		)
		lastPos = user.node.position

	ws.poll()
	var state = ws.get_ready_state()

	if lastState != state:
		print("state is ", state)
		lastState = state

	while ws.get_available_packet_count():
		var msg = JSON.parse_string(ws.get_packet().get_string_from_utf8())
		print("Server: ", JSON.stringify(msg))
		match msg.type:
			"user":
				user = msg
				user._id = 0
				send({ type = "topic", key = NetConfig.get_key(user) })

			"topic":
				if msg.rooms.is_empty(): send({ type = "room", name = "Creation" })
				else: send({ type = "room", id = msg.rooms.keys()[0] })

			"room":
				if not room:
					room = msg
					send({ type = "obj", obj = "Aye", x = 0, y = 0 })
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
								user._id = msg.id
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
	if event is InputEventMouseButton and not event.is_pressed():
		if not room: return
		send({ type = "obj", obj = "Aye", id = user._id,
				x = %Camera.position.x + event.position.x - 960 / 2,
				y = %Camera.position.y + event.position.y - 540 / 2 })


func send(msg):
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN: return
	outbox.push_back(msg)
