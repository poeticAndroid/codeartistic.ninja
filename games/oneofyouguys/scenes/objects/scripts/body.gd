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
@export var alive_shape: RectangleShape2D
@export var dead_shape: RectangleShape2D


enum Clan {RANDOM, ORANGE, GREEN, PURPLE}

const SPEED = 256
const JUMP_VELOCITY = -650.0
const GRAVITY = 2048

var health: float = 1
var alive: bool = true
var jumps: int = 0
var traitor: bool
var in_sight: Body
var carry: Body
var grasp: Body
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
		if Input.is_action_just_pressed("ui_left"):
			%AnimatedSprite2D.flip_h = true
		elif Input.is_action_just_pressed("ui_right"):
			%AnimatedSprite2D.flip_h = false
		if Input.is_action_just_pressed("ui_up"):
			jump()
		elif Input.is_action_just_pressed("ui_down"):
			drop()
		if Input.is_action_just_pressed("ui_accept"):
			fire()
	elif alive:  # AI is in control
		if is_on_wall():
			%AnimatedSprite2D.flip_h = not %AnimatedSprite2D.flip_h
			velocity.x = 64 + 64 * randf()
			if %AnimatedSprite2D.flip_h:
				velocity.x *= -1

	if velocity.x == 0:
		position = position.round()
	if position.y > get_viewport().size.y * 256:  # fell out of the world
		position.y = 0
		velocity.y = -100 * randf()
	move_and_slide()


func jump():
	if jumps > 0:
		jumps -= 1
		velocity.y += JUMP_VELOCITY


func fire():
	if %AnimatedSprite2D.flip_h:
		gun.shoot(self, position, Vector2(-1600, randf_range(-100, 100)), 0.2)
	else:
		gun.shoot(self, position, Vector2(1600, randf_range(-100, 100)), 0.2)


func damage(damage: float):
	health -= damage
	if health <= 0:
		kill()


func kill(pos = false):
	alive = false
	possessed = false
	clan += 4
	%AnimatedSprite2D.play("die")
	$CollisionShape2D.position = Vector2(0, 24)
	$CollisionShape2D.shape = dead_shape
	$CollisionShape2D/AnimatedSprite2D.position = Vector2(0, -24)
	velocity = Vector2.ZERO
	# if (this.carry && !this.carry.alive) {
	#   this.drop();
	# }
	# if (this.possessed && !pos) {
	#   setTimeout(() => {
	#     this.mapState.gameApp.goTo("lose_state");
	#   }, 1024);
	# };
	# this.exists =
	#   this.visible = true;
	# this.possessed =
	#   this.traitor = false;
	# this.play("die");
	# this.body.velocity.set(0);
	# this.body.setSize(32, 10, 0, 22);


func revive(health = 1):
	alive = true
	clan -= 4
	%AnimatedSprite2D.play("revive")
	$CollisionShape2D.position = Vector2(0, 0)
	$CollisionShape2D.shape = alive_shape
	$CollisionShape2D/AnimatedSprite2D.position = Vector2(0, 0)
	# super.revive(health);
	# setTimeout(() => {
	# 	if (this.alive) {
	# 		this.possessed = true;
	# 		(<GameState>this.mapState).leadingCamera.follow(this);
	# 	} else {
	# 		this.mapState.gameApp.goTo("lose_state");
	# 	}
	# }, 500);
	# this.play("revive");
	# this.body.setSize(16, 32, 8, 0);


func drop():
	# if (this.carry){
	# 		var carry = this.carry;
	# 		this.carry = null;
	# 		carry.drop();
	# }
	pass


func pickup(_carry = grasp):
	# if (this.carry != = carry){
	# 		this.drop();
	# 		this.carry = carry;
	# 		carry.pickup(this);
	# }
	pass


func possess():
	# if (!this.possessed) return;
	# if (!this.carry) return;
	# ( < GameState > this.mapState).leadingCamera.follow(null);
	# this.carry.revive();
	# this.kill(true);
	# this.playSound("posses");
	pass


func _on_on_screen() -> void:
	if alive and velocity.x == 0:
		velocity.x = -50 - 50 * randf()
