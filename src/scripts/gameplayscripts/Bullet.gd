extends Node2D

var attack: Attack
var hitbox: HitboxComponent = null

func _process(delta: float) -> void:
		global_position += transform.x * attack.bullet_speed * delta


func find_hitbox(children: Array[Node]):
	for child in children:
		if child.name == "HitboxComponent":
			hitbox = child

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	find_hitbox(body.get_children())
	if hitbox != null and body.is_in_group("Enemies"):
		hitbox.damage(self.attack)
		queue_free()



func _on_area_2d_body_exited(body: Node2D) -> void:
	hitbox = null
