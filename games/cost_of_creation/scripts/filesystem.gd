class_name FileSystem

static var crypto = Crypto.new()
static var key

static func make_key():
	if not FileSystem.key:
		if FileAccess.file_exists("user://secret.key"):
			print("loading key")
			FileSystem.key = FileAccess.get_file_as_bytes("user://secret.key")
		else:
			print("generating key")
			FileSystem.key = FileSystem.crypto.generate_random_bytes(32)
			print("saving key")
			var file = FileAccess.open("user://secret.key", FileAccess.WRITE)
			file.store_buffer(FileSystem.key)
			file.close()

static func get_file_as_bytes(path: String):
	print("reading ", path)
	FileSystem.make_key()
	var file = FileAccess.open_encrypted(path, FileAccess.READ, FileSystem.key)
	var bytes = PackedByteArray()
	if file:
		bytes = file.get_buffer(file.get_length())
		file.close()
	return bytes

static func put_file_as_bytes(path: String, bytes: PackedByteArray):
	print("writing ", path)
	FileSystem.make_key()
	var file = FileAccess.open_encrypted(path, FileAccess.WRITE, FileSystem.key)
	file.store_buffer(bytes)
	file.close()

static func get_file_as_json(path: String):
	return JSON.parse_string(FileSystem.get_file_as_bytes(path).get_string_from_utf8())

static func put_file_as_json(path: String, obj):
	return FileSystem.put_file_as_bytes(path, JSON.stringify(obj).to_utf8_buffer())
