@tool
class_name Body
extends CharacterBody2D

@export var clan: Clan:
	set(_clan):
		clan = _clan
		match clan:
			Clan.RANDOM: %AnimatedSprite2D.modulate = Color.WHITE
			Clan.ORANGE: %AnimatedSprite2D.modulate = Color("FF9200")
			Clan.GREEN: %AnimatedSprite2D.modulate = Color("74FF00")
			Clan.PURPLE: %AnimatedSprite2D.modulate = Color("6E01FF")
@export var possessed: bool


enum Clan {RANDOM, ORANGE, GREEN, PURPLE}

const SPEED = 130.0
const JUMP_VELOCITY = -650.0
const GRAVITY = 2048

var alive: bool = true
var jumps: int = 0
var traitor: bool
var in_sight: Body
var carry: Body
var grasp: Body

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%AnimatedSprite2D.flip_h = !possessed
	if Engine.is_editor_hint(): return
	if clan == Clan.RANDOM:
		clan = randi_range(1, 3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if is_on_floor():
		jumps = 1
	else:
		velocity.y += GRAVITY * delta

	if possessed:  # player is in control
		velocity.x = Input.get_axis("ui_left", "ui_right") * 256
		if Input.is_action_just_pressed("ui_left"):
			%AnimatedSprite2D.flip_h = true
		if Input.is_action_just_pressed("ui_right"):
			%AnimatedSprite2D.flip_h = false
		if Input.is_action_just_pressed("ui_up"):
			jump()
		if Input.is_action_just_pressed("ui_down"):
			drop()
		if Input.is_action_just_pressed("ui_accept"):
			fire()
	elif alive:  # AI is in control
		if velocity.x == 0:
			velocity.x = -50 - 50 * randf()
		if is_on_wall():
			%AnimatedSprite2D.flip_h = ! %AnimatedSprite2D.flip_h
			velocity.x = 64 + 64 * randf()
			if %AnimatedSprite2D.flip_h:
				velocity.x *= -1

	move_and_slide()


func jump():
	if jumps > 0:
		jumps -= 1
		velocity.y += JUMP_VELOCITY


func fire():
	pass


func kill(pos = false):
	pass


func revive(health = 1):
	pass


func drop():
	pass


func pickup(_carry = grasp):
	pass


func possess():
	pass








### Typescript source

# /// <reference path="../../_d.ts/phaser/phaser.d.ts"/>
# "use strict";
# import GameState = require("../states/GameState");
# import MapSprite = require("../lib/MapSprite");
# import joypad = require("../lib/joypad");

# /**
#  * Body class
#  */

# class Body extends MapSprite {
#   public jumps: number;
#   public gun: Phaser.Particles.Arcade.Emitter;
#   public possessed: boolean;
#   public clan: string;
#   public traitor = false;
#   public sfx: Phaser.Sound;
#   public inSight: Body;
#   public carry: Body;
#   public grasp: Body;

#   constructor(mapState: GameState, object: any) {
#     super(mapState, object);
#     this.autoCull = false;
#     this.renderable = false;
#     this.clan = this.getProperty("clan") || Phaser.ArrayUtils.getRandomItem(["orange", "green", "purple"]);
#     switch (this.clan) {
#       case "orange":
#         this.tint = 0xFF9200;
#         break;
#       case "green":
#         this.tint = 0x74FF00;
#         break;
#       case "purple":
#         this.tint = 0x6E01FF;
#         break;
#     }
#     this.moveAnchor(.5, 1);
#     this.possessed = !!(this.getProperty("possessed"));

#     this.body.setSize(16, 32, 8, 0);
#     this.scale.set(this.possessed ? 2 : -2, 2);
#     this.body.bounce.set(.1);

#     this.animations.add("idle", [0], 15, true);
#     this.animations.add("walk", [0, 1, 2, 1]), 6, true;
#     this.animations.add("die", [0, 1, 2, 3, 4, 5, 6, 7, 8], 15, false);
#     this.animations.add("revive", [8, 7, 6, 5, 4, 3, 2, 1, 0], 15, false);

#     this.sfx = this.game.add.audio("body_sfx");
#     this.sfx.addMarker("jump", 0.0, 0.25);
#     this.sfx.addMarker("fire", 0.5, 0.25);
#     this.sfx.addMarker("damage", 1.0, 0.25);
#     this.sfx.addMarker("posses", 1.5, 1.8);

#     this.mapState.objectType("bullet").add(this.gun = this.game.add.emitter(this.x, this.y, 10));
#     this.gun["owner"] = this;
#     this.gun.gravity = -2048;
#     this.gun.setScale(.25, .25, .25, .25);
#     this.gun.minParticleScale =
#       this.gun.maxParticleScale = .25;
#     this.gun.makeParticles("swatches_32x32", 2, 10, true);

#     joypad.start();
#   }

#   update() {
#     if (this.inCamera && !this.renderable) {
#       this.body.velocity.x = -50 - Math.random() * 50;
#       this.renderable = true;
#     }
#     if (!this.renderable) return;
#     super.update();
#     var dir = this.scale.x / Math.abs(this.scale.x);
#     if (this.body.onFloor()) {
#       this.jumps = 1;
#     }

#     this.inSight = null;
#     if (this.alive && !this.possessed) { // living AI
#       this.mapState.objectTypes["body"].forEachAlive(function (other: Body) { // looking for enemies
#         if (other === this) return;
#         if (Math.abs(this.y - other.y) < 32) { // must be on same vertical level
#           if (other.traitor && Math.abs(this.x - other.x) < 400) { // make sure to face traitor
#             if (dir < 0 && other.x > this.x) {
#               dir = 1;
#               this.scale.x = Math.abs(this.scale.x);
#               this.body.velocity.x = 128 * Math.random();
#               if (this.body.onFloor()) {
#                 this.jump();
#               }
#             }
#             if (dir > 0 && other.x < this.x) {
#               dir = -1;
#               this.scale.x = -Math.abs(this.scale.x);
#               this.body.velocity.x = -128 * Math.random();
#               if (this.body.onFloor()) {
#                 this.jump();
#               }
#             }
#           }
#           if (Math.abs(this.x - other.x) < (this.inSight ? Math.abs(this.x - this.inSight.x) : 200)) { // detect if facing
#             if (dir < 0 && other.x < this.x) {
#               this.inSight = other;
#             }
#             if (dir > 0 && other.x > this.x) {
#               this.inSight = other;
#             }
#           }
#         }
#       }, this);
#     }

#     if (this.possessed) { // player is in control
#       this.body.velocity.x = joypad.x * 256;
#       if (joypad.x < 0) {
#         this.scale.x = -Math.abs(this.scale.x);
#       }
#       if (joypad.x > 0) {
#         this.scale.x = Math.abs(this.scale.x);
#       }

#       if (joypad.deltaUp === 1) {
#         this.jump();
#       }
#       if (joypad.deltaDown === 1) {
#         this.drop();
#       }
#       if (joypad.deltaA === 1) {
#         this.fire();
#       }
#       if (joypad.b) {
#         if (this.grasp) {
#           this.pickup();
#         }
#         this.possess();
#       }
#     } else if (this.alive) { // living AI
#       if (this.body.onWall()) {
#         if (dir > 0) {
#           this.scale.x = -Math.abs(this.scale.x);
#           this.body.velocity.x = -64;
#           this.body.velocity.x -= 64 * Math.random();
#         } else {
#           this.scale.x = Math.abs(this.scale.x);
#           this.body.velocity.x = 64;
#           this.body.velocity.x += 64 * Math.random();
#         }
#       }
#       if (this.inSight) {
#         if (this.inSight.traitor) {
#           this.traitor = false;
#           if (Math.random() < (10 / 60)) this.fire();
#         }
#         if (this.clan !== this.inSight.clan) {
#           if (Math.random() < (2 / 60)) this.fire();
#         }
#       }
#     } else if (this.carry) { // dead and carried
#       this.position.set(this.carry.x, this.carry.y - this.carry.height);
#       this.body.velocity.set(0);
#     }

#     if (this.y > this.game.world.height * 2) { // fell out of the world
#       this.y = 0;
#       this.body.velocity.y = -100 * Math.random();
#     }
#     this.grasp = null;
#   }

#   jump() {
#     if (this.jumps > 0) {
#       this.jumps--;
#       this.body.velocity.y = -650;
#       this.playSound("jump");
#     }
#   }

#   fire() {
#     // if (this.carry) return this.drop();
#     var dir = this.scale.x / Math.abs(this.scale.x);
#     this.gun.x = this.x;
#     this.gun.y = this.y - this.height / 2;
#     this.gun.setXSpeed(1600 * dir, 1600 * dir);
#     this.gun.start(true, 200, null, 1);
#     this.playSound("fire");
#   }

#   kill(pos = false) {
#     super.kill();
#     if (this.carry && !this.carry.alive) {
#       this.drop();
#     }
#     if (this.possessed && !pos) {
#       setTimeout(() => {
#         this.mapState.gameApp.goTo("lose_state");
#       }, 1024);
#     };
#     this.exists =
#       this.visible = true;
#     this.possessed =
#       this.traitor = false;
#     this.play("die");
#     this.body.velocity.set(0);
#     this.body.setSize(32, 10, 0, 22);
#     return this;
#   }

#   revive(health = 1) {
#     super.revive(health);
#     setTimeout(() => {
#       if (this.alive) {
#         this.possessed = true;
#         (<GameState>this.mapState).leadingCamera.follow(this);
#       } else {
#         this.mapState.gameApp.goTo("lose_state");
#       }
#     }, 500);
#     this.play("revive");
#     this.body.setSize(16, 32, 8, 0);
#     return this;
#   }

#   drop() {
#     if (this.carry) {
#       var carry = this.carry;
#       this.carry = null;
#       carry.drop();
#     }
#   }

#   pickup(carry = this.grasp) {
#     if (this.carry !== carry) {
#       this.drop();
#       this.carry = carry;
#       carry.pickup(this);
#     }
#   }

#   possess() {
#     if (!this.possessed) return;
#     if (!this.carry) return;
#     (<GameState>this.mapState).leadingCamera.follow(null);
#     this.carry.revive();
#     this.kill(true);
#     this.playSound("posses");
#   }

# }
# export = Body;
