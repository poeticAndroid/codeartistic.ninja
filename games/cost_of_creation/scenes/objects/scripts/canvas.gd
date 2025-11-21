extends Sprite2D

var color: Image
var brush: Image

var img: Image
var line_start = Vector2.ZERO
var line_end = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color = Image.load_from_file("res://games/cost_of_creation/assets/sprites/circle8px.png")
	color.convert(Image.FORMAT_RGBA8)
	brush = Image.load_from_file("res://games/cost_of_creation/assets/sprites/circle8px.png")
	brush.convert(Image.FORMAT_RGBA8)
	img = Image.create_empty(960, 540, false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(img)
	set_color(Color.BLUE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	var mouse_pos = Vector2.ZERO
	if event is InputEventMouse:
		mouse_pos = event.position - Vector2(480, 270)
		line_end = event.position
		if event.button_mask:
			line(line_start, line_end)
		line_start = line_end


func clear():
	img.fill(Color.TRANSPARENT)
	texture.update(img)


func set_color(c):
	color.fill(c)


func line(from, to):
	var delta = to - from
	var len = max(abs(delta.x), abs(delta.y))
	for i in range(len):
		img.blend_rect_mask(color, brush, brush.get_used_rect(), Vector2(-4, -4) + from + delta * (i / len))
	texture.update(img)
