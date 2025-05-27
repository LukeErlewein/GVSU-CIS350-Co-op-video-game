extends Area2D

signal exploded(position: Vector2)

@export var speed: float = 100
@export var lifetime: float = 1.5
@export var explosion_animation: String = "GrenadeExplosion"
@export var is_piercing: bool = false

var attack: Attack
var hitbox: HitboxComponent = null
var animation_name: String = "GrenadeProjectile"
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
	if hitbox != null and body.is_in_group("Enemies"):
		hitbox.damage(attack)
		if not is_piercing:
			_explode()

func _on_area_2d_body_exited(body: Node2D) -> void:
	hitbox = null

func find_hitbox(children: Array[Node]):
	for child in children:
		if child.name == "HitboxComponent":
			hitbox = child

func play(anim_name: String = "GrenadeProjectile"):
	animation_name = anim_name

	for child in get_children():
		if child is AnimatedSprite2D:
			child.visible = false

	var anim_node = get_node_or_null(anim_name)
	if anim_node and anim_node.has_method("play"):
		anim_node.visible = true
		anim_node.play(animation_name)
	else:
		push_warning("Animation node '%s' not found or missing play() method." % anim_name)


func _explode():
	if has_exploded:
		return
	has_exploded = true

	body_entered.disconnect(_on_area_2d_body_entered)
	body_exited.disconnect(_on_area_2d_body_exited)

	emit_signal("exploded", global_position)

	speed = 0
	for child in get_children():
		if child is AnimatedSprite2D:
			child.visible = false
			
	if explosion_animation != "":
		var anim_node = get_node_or_null(explosion_animation)
		anim_node.visible = true
		anim_node.play(explosion_animation)
		anim_node.animation_finished.connect(Callable(self, "_on_explosion_animation_finished"))
	else:
		queue_free()


func _on_explosion_animation_finished():
	queue_free()
