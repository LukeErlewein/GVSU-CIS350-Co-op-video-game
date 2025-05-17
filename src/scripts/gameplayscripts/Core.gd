class_name Core extends Area2D

func _ready():
	pass

var currentPower := 0
@export var MAXPOWER := 100

# Signal connection
func add_power(amount: int) -> void:
	currentPower += amount
	currentPower = clamp(currentPower, 0, MAXPOWER)
	print("Power Core charged. Current power:", currentPower, "/", MAXPOWER)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		print("Enemy area entered:", area.name)
		var attack = Attack.new()
		var hitbox = get_node_or_null("HitboxComponent")
		if hitbox:
			hitbox.damage(attack)


func _on_button_pressed() -> void:
	add_power(1)	 # Replace with function body.
