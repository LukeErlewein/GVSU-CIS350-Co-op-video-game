class_name HitboxComponent extends Area2D

@export var health_component : HealthComponent

func damage(attack: Attack):
	if health_component:
		health_component.damage(attack)
		
func _ready():
	if health_component == null:
		# Try to auto-assign by searching the parent
		if get_parent().has_node("HealthComponent"):
			health_component = get_parent().get_node("HealthComponent")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
