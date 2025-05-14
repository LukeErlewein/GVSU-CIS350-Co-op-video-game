extends Node2D

var attack: Attack
var direction:= Vector2.ZERO

func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		var velocity = direction * attack.bullet_speed
		
		global_position += velocity



func set_direction(direction: Vector2):
	self.direction = direction

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is HitboxComponent:
		var hitbox: HitboxComponent = body
		hitbox.damage(self.attack)
