extends Sprite2D

var aye: Node

var color: Image
var brush: Image

var img: Image
var line_start = Vector2.ZERO
var line_end = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color = preload("res://games/cost_of_creation/assets/sprites/circle8px.png").get_image()
	color.convert(Image.FORMAT_RGBA8)
	brush = preload("res://games/cost_of_creation/assets/sprites/circle8px.png").get_image()
	brush.convert(Image.FORMAT_RGBA8)
	img = Image.create_empty(960, 540, false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(img)
	set_color(Color.BLUE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not aye: return


func _input(event: InputEvent) -> void:
	if not aye: return
	set_color(Color.from_ok_hsl(aye.ink_color.hue, aye.ink_color.saturation, aye.ink_color.lightness))
	if event is InputEventMouse:
		line_end = event.position
		if event.button_mask and aye.ink_fill > 0:
			line(line_start, line_end)
		line_start = line_end


func clear():
	img.fill(Color.TRANSPARENT)
	texture.update(img)


func set_color(c):
	color.fill(c)


func line(from, to):
	if not aye: return
	if aye.ink_fill <= 0: return
	var delta = to - from
	aye.set_ink_fill(aye.ink_fill - delta.length() * 0.0001)
	var len = max(abs(delta.x), abs(delta.y))
	for i in range(len):
		img.blend_rect_mask(color, brush, brush.get_used_rect(), Vector2(-4, -4) + from + delta * (i / len))
	texture.update(img)


func get_changed():
	return img.get_region(img.get_used_rect())


func to_obj():
	var imgdata = get_changed().save_png_to_buffer().hex_encode()
	return {
			type = "obj", obj = "Canvas", id = "none",
			left = position.x - 480 + img.get_used_rect().position.x,
			top = position.y - 270 + img.get_used_rect().position.y,
			png = imgdata,
		}
