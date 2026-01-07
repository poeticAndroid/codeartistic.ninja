extends Sprite2D

@export var col = 0
@export var row = 0

var world_dir = "user://creation/"

var img: Image


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	img = Image.create_empty(512, 512, false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(img)
	goto(col, row)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func goto(_col, _row):
	col = _col
	row = _row
	img.fill(Color.TRANSPARENT)
	texture.update(img)

	position.x = 256 + col * 512
	position.y = 256 + row * 512
	img.load_png_from_buffer(FileAccess.get_file_as_bytes(world_dir + str(col) + "_" + str(row) + ".png"))
	img.load_png_from_buffer(FileSystem.get_file_as_bytes(world_dir + "tile_" + str(col) + "_" + str(row)))
	texture.update(img)
