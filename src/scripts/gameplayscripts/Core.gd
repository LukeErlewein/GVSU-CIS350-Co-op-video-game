class_name Core extends Area2D

func _ready():
	pass

var currentPower := 0
@export var MAXPOWER := 100
signal power_updated(new_power: int)

# Signal connection
@rpc("call_local")
func add_power(amount: int) -> void:
	currentPower += amount
	currentPower = clamp(currentPower, 0, MAXPOWER)
	print("Power Core charged. Current power:", currentPower, "/", MAXPOWER)
	emit_signal("power_updated", currentPower)


func _on_button_pressed() -> void:
	add_power.rpc(5)
