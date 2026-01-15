class_name FileSystem

static var crypto = Crypto.new()
static var key
static var lock

static func make_key():
	if not FileSystem.key:
		if FileAccess.file_exists("user://secret.key"):
			FileSystem.key = FileAccess.get_file_as_bytes("user://secret.key")
		else:
			FileSystem.key = FileSystem.crypto.generate_random_bytes(32)
			var file = FileAccess.open("user://secret.key", FileAccess.WRITE)
			file.store_buffer(FileSystem.key)
			file.close()

static func file_exists(path: String):
	return FileAccess.file_exists(path)

static func get_file_as_bytes(path: String):
	FileSystem.make_key()
	var file = FileAccess.open_encrypted(path, FileAccess.READ, FileSystem.key)
	var bytes = PackedByteArray()
	if file:
		bytes = file.get_buffer(file.get_length())
		file.close()
	return bytes

static func put_file_as_bytes(path: String, bytes: PackedByteArray):
	if path.get_file() != "lock":
		if FileSystem.lock and FileSystem.file_exists("user://lock"):
			if FileSystem.get_file_as_json("user://lock") != FileSystem.lock:
				return Global.go_back()
		else:
			FileSystem.lock = Time.get_unix_time_from_system()
			FileSystem.put_file_as_json("user://lock", FileSystem.lock)
	FileSystem.make_key()
	var file = FileAccess.open_encrypted(path, FileAccess.WRITE, FileSystem.key)
	file.store_buffer(bytes)
	file.close()

static func get_file_as_json(path: String):
	return JSON.parse_string(FileSystem.get_file_as_bytes(path).get_string_from_utf8())

static func put_file_as_json(path: String, obj):
	return FileSystem.put_file_as_bytes(path, JSON.stringify(obj).to_utf8_buffer())

static func remove_absolute(path):
	if FileSystem.get_file_as_json("user://lock") != FileSystem.lock: return
	DirAccess.remove_absolute(path)
