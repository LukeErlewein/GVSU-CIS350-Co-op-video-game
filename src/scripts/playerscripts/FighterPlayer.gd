class_name FighterPlayer extends CharacterBody2D

@export var SPEED: float = 55
@export var ACCELERATION: float = 5
@export var FRICTION: float = 8

@export var bullet : PackedScene
@onready var muzzle: Marker2D = $Muzzle
@onready var shot_cooldown_timer: Timer = $ShotCooldownTimer
@onready var camera: Camera2D = $Camera2D

var attack: Attack
var can_shoot: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_multiplayer_authority(): camera.make_current()
	attack = Attack.new()
	attack.attack_damage = 1.0
	attack.bullet_speed = 40.0
	attack.knockback_force = 10.0
	attack.attack_cooldown = 0.2

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Only let the correct user control the character
	if !is_multiplayer_authority():
		return
	
	# Get direction of movement
	var input = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	# get ACCELERATION or FRICTION depending on input
	var lerp_weight = delta * (ACCELERATION if input else FRICTION)
	# apply to character velocity
	velocity = lerp(velocity, input * SPEED, lerp_weight)
	# apply movement
	move_and_slide()
	# Rotate player towards mouse
	look_at(get_global_mouse_position())
	
	# Player shoots on "shoot" action if cooldown bool is true
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot.rpc()

@rpc("call_local")
func shoot():
	can_shoot = false
	var bullet_instance = bullet.instantiate()
	bullet_instance.transform = muzzle.global_transform
	bullet_instance.attack = self.attack
	get_parent().add_child(bullet_instance)
	shot_cooldown_timer.start(attack.attack_cooldown)
	

func _on_shot_cooldown_timer_timeout() -> void:
	can_shoot = true
