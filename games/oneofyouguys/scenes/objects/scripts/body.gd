@tool
@icon("./icons/body.png")
class_name Body
extends CharacterBody2D

signal on_screen

@export var clan: Clan:
	set(_clan):
		clan = _clan
		if not %AnimatedSprite2D: await ready
		match clan:
			Clan.RANDOM:
				%AnimatedSprite2D.modulate = Color.WHITE
				collision_mask = 1 | 32 | 64 | 128
			Clan.ORANGE:
				%AnimatedSprite2D.modulate = Color("FF9200")
				collision_mask = 1 | 16 | 64 | 128
			Clan.GREEN:
				%AnimatedSprite2D.modulate = Color("74FF00")
				collision_mask = 1 | 16 | 32 | 128
			Clan.PURPLE:
				%AnimatedSprite2D.modulate = Color("6E01FF")
				collision_mask = 1 | 16 | 32 | 64
			_:
				collision_mask = 1
@export var possessed: bool:
	set(_possessed):
		possessed = _possessed
		if possessed: add_to_group("possessed")
		else: remove_from_group("possessed")
		if not Engine.is_editor_hint(): return
		if not %AnimatedSprite2D: await ready
		%AnimatedSprite2D.flip_h = false if possessed else true
@export var alive_shape: RectangleShape2D
@export var dead_shape: RectangleShape2D

enum Clan { RANDOM, ORANGE, GREEN, PURPLE }

const SPEED = 256
const JUMP_VELOCITY = -650.0
const GRAVITY = 2048

var health: float = 1
var alive: bool = true
var jumps: int = 0
var traitor: bool
var carry: Body
var grasp: Body
var detected: Array[Body] = []
@onready var gun: Node = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%AnimatedSprite2D.flip_h = false if possessed else true
	if Engine.is_editor_hint(): return
	if clan == Clan.RANDOM:
		clan = randi_range(1, 3)
	while gun and not gun.has_method("shoot"):
		gun = gun.get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if is_on_floor():
		jumps = 1
	else:
		velocity.y += GRAVITY * delta

	if possessed:  # player is in control
		velocity.x = Input.get_axis("ui_left", "ui_right") * SPEED
		if velocity.x < 0:
			%AnimatedSprite2D.flip_h = true
		elif velocity.x > 0:
			%AnimatedSprite2D.flip_h = false
		if Input.is_action_just_pressed("ui_up"):
			jump()
		elif Input.is_action_just_pressed("ui_down"):
			drop()
		if Input.is_action_just_pressed("ui_accept"):
			fire()
		if Input.is_action_just_pressed("ui_select"):
			if grasp: pickup()
			possess()
	elif alive:  # AI is in control
		if is_on_wall():
			%AnimatedSprite2D.flip_h = not %AnimatedSprite2D.flip_h
			velocity.x = 64 + 64 * randf()
			if %AnimatedSprite2D.flip_h:
				velocity.x *= -1

		for body in detected:
			if body.traitor:
				if %AnimatedSprite2D.flip_h == true and body.position.x > position.x:
					%AnimatedSprite2D.flip_h = false
					velocity.x = randf() * 128
					if is_on_floor(): jump()
				if %AnimatedSprite2D.flip_h == false and body.position.x < position.x:
					%AnimatedSprite2D.flip_h = true
					velocity.x = randf() * -128
					if is_on_floor(): jump()

		var right = $SightRight.get_collider()
		var left = $SightLeft.get_collider()
		var in_sight: Body

		if %AnimatedSprite2D.flip_h == true and left is Body:
			in_sight = left
		if %AnimatedSprite2D.flip_h == false and right is Body:
			in_sight = right

		if in_sight:
			if in_sight.traitor:
				traitor = false
				if randf() < (10.0 / 60.0): fire()
			if in_sight.clan != clan:
				if randf() < (2.0 / 60.0): fire()
	elif carry:  # dead and carried
		position.x = carry.position.x
		position.y = carry.position.y - 64
		velocity = Vector2.ZERO

	if velocity.x == 0:
		position = position.round()
	if position.y < 0:
		position.y = 0
		velocity = Vector2.ONE
	if position.y > get_viewport().size.y * 256:  # fell out of the world
		position.y = 0
		velocity.y = -100 * randf()
	move_and_slide()


func jump():
	if jumps > 0:
		jumps -= 1
		velocity.y += JUMP_VELOCITY
		$Sfx/Jump.play()


func fire():
	if not gun: return
	if velocity.x == 0 and not possessed: return
	if %AnimatedSprite2D.flip_h:
		gun.shoot(self, position, Vector2(-1600, randf_range(-100, 100)), 0.2)
	else:
		gun.shoot(self, position, Vector2(1600, randf_range(-100, 100)), 0.2)
	$Sfx/Shoot.play()


func damage(damage: float):
	health -= damage
	$Sfx/Damage.play()
	if health <= 0:
		kill()


func kill(pos = false):
	if not alive: return
	if carry and not carry.alive:
		drop()
	alive = false
	traitor = false
	clan += 4
	%AnimatedSprite2D.position = Vector2(0, -24)
	$CollisionShape2D.position = Vector2(0, 24)
	$CollisionShape2D.shape = dead_shape
	velocity = Vector2.ZERO
	%AnimatedSprite2D.play("die")
	if possessed:
		possessed = false
		if not pos:
			await get_tree().create_timer(1).timeout
			Global.goto_scene("lose", false)


func revive(_health = 1):
	if alive: return
	health = _health
	alive = true
	clan -= 4
	%AnimatedSprite2D.position = Vector2(0, -1)
	$CollisionShape2D.position = Vector2(0, 1)
	$CollisionShape2D.shape = alive_shape
	velocity = Vector2.ZERO
	%AnimatedSprite2D.play("revive")
	await %AnimatedSprite2D.animation_finished
	if alive:
		possessed = true
	else:
		Global.goto_scene("lose", false)


func drop():
	if carry:
		var _carry = carry
		carry = null
		_carry.drop()


func pickup(_carry: Body = grasp):
	if carry != _carry:
		drop()
		carry = _carry
		_carry.pickup(self)


func possess():
	if not possessed: return
	if not carry: return
	carry.revive()
	kill(true)
	$Sfx/Possess.play()


func _on_on_screen() -> void:
	if alive and velocity.x == 0 and %AnimatedSprite2D.animation == "idle":
		velocity.x = -50 - 50 * randf()


func _on_area_2d_body_entered(body: Body) -> void:
	if body == self: return
	if body.alive: return
	grasp = body


func _on_area_2d_body_exited(body: Body) -> void:
	if body != grasp: return
	grasp = null


func _on_traitor_detector_body_entered(body: Body) -> void:
	if possessed: return
	if not alive: return
	detected.append(body)


func _on_traitor_detector_body_exited(body: Node2D) -> void:
	detected.erase(body)
