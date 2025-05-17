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


func _on_button_pressed() -> void:
	add_power(1)	 # Replace with function body.
