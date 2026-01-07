class_name NetConfig

static var servers = ["ws://127.0.0.1:9001/ws/chat"]

static func get_key(user):
	return "ItXbqOd6UqUTxk7Xg185zA_" + user.name
