class_name Core extends Area2D

func _ready():
	pass

var currentPower := 0
@export var MAXPOWER := 100
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent

signal power_updated(new_power: int)
signal game_won
signal game_lost

func _physics_process(delta: float) -> void:
	if health_component.health <= 0:
		game_lost.emit()
	if currentPower >= 100.0:
		game_won.emit()

@rpc("authority")
func add_power(amount: int) -> void:
	currentPower += amount
	currentPower = clamp(currentPower, 0, MAXPOWER)
	print("Power Core charged. Current power:", currentPower, "/", MAXPOWER)
	rpc("sync_power", currentPower)

@rpc("call_local")
func sync_power(new_power: int) -> void:
	currentPower = new_power
	emit_signal("power_updated", currentPower)


func _on_button_pressed() -> void:
	add_power(5)
	add_power.rpc(5)


func _on_hitbox_component_body_entered(body: Node2D) -> void:
	if body is Grunt:
		hitbox_component.damage(body.attack)
		body.queue_free()
