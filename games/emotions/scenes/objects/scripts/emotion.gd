extends Node2D

var velocity = Vector2(randf_range(-8, 8), randf_range(-8, 8))

const emojis = "😀😁😂😃😄😅😆😇😈😉😊😋😌😍😎😏😐😑😒😓😔😕😖😗😘😙😚😛😜😝😞😟😠😡😢😣😤😥😦😧😨😩😪😫😬😭😮😯";


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Label.text = emojis.substr(randi_range(0, emojis.length() - 1), 1)
	position = get_parent().aye.position
	await get_tree().create_tween().tween_property(self, "modulate:a", 0, 2).finished
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity
