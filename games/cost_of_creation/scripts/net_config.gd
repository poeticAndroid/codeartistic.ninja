class_name NetConfig

static var servers = [
		"wss://hotater-eu.onrender.com/ws/chat",
		"ws://127.0.0.1:9001/ws/chat",
	]

static func get_key(user):
	return (user.id + "@Creation_9oaoK3A8Av4u5Sc6RaGQAUtUuxQONbCy").sha256_text()
