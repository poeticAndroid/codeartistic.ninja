class_name FileSystem

static var crypto = Crypto.new()
static var key
static var lock


static func make_key():
	if not FileSystem.lock:
		FileSystem.lock = str(OS.get_process_id())
		var file = FileAccess.open("user://lock", FileAccess.WRITE)
		file.store_string(FileSystem.lock)
		file.close()
		print("New fileSystem lock! ", FileSystem.lock)
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
	var bytes = PackedByteArray()
	if not FileSystem.file_exists(path): return bytes
	var file = FileAccess.open_encrypted(path, FileAccess.READ, FileSystem.key)
	if file:
		bytes = file.get_buffer(file.get_length())
		file.close()
	else:
		print("Error ", FileAccess.get_open_error(), " opening ", path, " for reading! ")
	return bytes


static func put_file_as_bytes(path: String, bytes: PackedByteArray):
	FileSystem.make_key()
	if path.get_file() != "lock":
		var lock = FileAccess.get_file_as_string("user://lock")
		if lock != FileSystem.lock:
			print("FileSystem locked by another process! ", FileSystem.lock, " ", lock)
			return Global.go_back()
	var tmp = path.get_base_dir() + "/" + "tmp_" + str(abs(randi()))
	var file = FileAccess.open_encrypted(tmp, FileAccess.WRITE, FileSystem.key)
	if file:
		file.store_buffer(bytes)
		file.close()
	else:
		print("Error ", FileAccess.get_open_error(), " opening ", tmp, " for writing! ")
	if FileSystem.file_exists(tmp):
		DirAccess.rename_absolute(tmp, path)


static func get_file_as_json(path: String):
	return JSON.parse_string(FileSystem.get_file_as_bytes(path).get_string_from_utf8())


static func put_file_as_json(path: String, obj):
	return FileSystem.put_file_as_bytes(path, JSON.stringify(obj).to_utf8_buffer())


static func remove_absolute(path):
	if FileSystem.get_file_as_json("user://lock") != FileSystem.lock: return
	DirAccess.remove_absolute(path)
