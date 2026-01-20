extends Sprite2D

@export var col = 0
@export var row = 0

var world_dir

var img: Image


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	img = Image.create_empty(256, 256, false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(img)
	$ColorRect1.visible = OS.is_debug_build()
	$ColorRect2.visible = OS.is_debug_build()
	$ColorRect3.visible = OS.is_debug_build()
	$ColorRect4.visible = OS.is_debug_build()
	$Label.visible = OS.is_debug_build()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func goto(_col, _row):
	if col != int(_col) or col != int(_col):
		img.fill(Color.TRANSPARENT)
		texture.update(img)
	col = int(_col)
	row = int(_row)
	position.x = 128 + col * 256
	position.y = 128 + row * 256
	$Label.text = str(col) + ", " + str(row)
	await get_tree().create_timer(randf()).timeout
	if col != int(_col): return
	if row != int(_row): return

	world_dir = get_parent().get_parent().world_dir

	var file = "tile_" + str(col) + "_" + str(row)
	if FileSystem.file_exists(world_dir + file):
		img.load_png_from_buffer(FileSystem.get_file_as_bytes(world_dir + file))
	texture.update(img)

	#if not img.get_used_rect().has_area():
		#FileSystem.remove_absolute(world_dir + file)
		#$Label.text += "\ndeleted!"
