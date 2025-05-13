extends CharacterBody2D

@export var SPEED: float = 55
@export var ACCELERATION: float = 5
@export var FRICTION: float = 8

@export var bullet : PackedScene
@onready var muzzle: Marker2D = $Muzzle
var attack: Attack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack = Attack.new()
	attack.attack_damage = 1.0
	attack.bullet_speed = 40.0
	attack.knockback_force = 10.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("shoot"):
		shoot()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	
	look_at(get_global_mouse_position())

func shoot():
	print("FighterPlayer Shot")
	var bullet_instance = bullet.instantiate()
	bullet_instance.transform = muzzle.global_transform
	var mouse_direction = bullet_instance.global_position.direction_to(get_global_mouse_position()).normalized()
	attack.attack_position = mouse_direction
	bullet_instance.attack = self.attack
	bullet_instance.set_direction(mouse_direction)
	owner.add_child(bullet_instance)
	
