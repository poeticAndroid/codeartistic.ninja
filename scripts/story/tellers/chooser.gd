extends Control

var story: Node
var line: String
var tree: TextTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("reveal")
	var num = 0
	for child in tree.children:
		var title = story.eval_line(child.line)
		while child and not title:
			title = story.eval_line(child.line)
			child = child.get_child(0)
		if title:
			var choice = %Choice.duplicate()
			choice.text = title
			choice.pressed.connect(_on_choice_pressed.bind(num))
			choice.mouse_entered.connect(_on_choice_mouse_entered.bind(num))
			%Choices.add_child(choice)
		num += 1
	%Choice.queue_free()
	await get_tree().create_timer(0.02).timeout
	_on_choice_mouse_entered(0)
	custom_minimum_size.y = %Choices.size.y + 32


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_choice_pressed(num: int) -> void:
	if story:
		story.new_passage()
		story.goto("0" + " +".repeat(num))
	$AnimationPlayer.play_backwards("reveal")
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "custom_minimum_size:y", 0, 1)
	for child in %Choices.get_children():
		if num != 0:
			tween = create_tween()
			tween.set_trans(Tween.TRANS_QUAD)
			tween.tween_property(child, "modulate:a", 0, 0.5)
		num += -1
	await $AnimationPlayer.animation_finished
	queue_free()


func _on_choice_mouse_entered(num: int = 0) -> void:
	for child in %Choices.get_children():
		if num == 0: child.grab_focus()
		num += -1
