extends Area2D

signal exploded(position: Vector2)

@export var speed: float = 100
@export var lifetime: float = 1.5

var attack: Attack
var hitbox: HitboxComponent = null
var animation_name: String = "Grenade"
var has_exploded := false


func _ready():
	body_entered.connect(_on_area_2d_body_entered)
	body_exited.connect(_on_area_2d_body_exited)

	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		_explode()

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	find_hitbox(body.get_children())
	if hitbox != null and (body.is_in_group("Enemies")):
		hitbox.damage(attack)
		_explode()

func _on_area_2d_body_exited(body: Node2D) -> void:
	hitbox = null

func find_hitbox(children: Array[Node]):
	for child in children:
		if child.name == "HitboxComponent":
			hitbox = child

func play(anim_name: String = "Grenade"):
	animation_name = anim_name
	$AnimatedSprite2D.play(animation_name)

func _explode():
	if has_exploded:
		return
	has_exploded = true

	body_entered.disconnect(_on_area_2d_body_entered)
	body_exited.disconnect(_on_area_2d_body_exited)

	emit_signal("exploded", global_position)
	
	$AnimatedSprite2D.play("Explosion")
	speed = 0
	# Wait for animation to finish, then free
	$AnimatedSprite2D.animation_finished.connect(Callable(self, "_on_explosion_animation_finished"))

func _on_explosion_animation_finished():
	queue_free()
