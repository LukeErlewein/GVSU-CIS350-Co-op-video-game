extends Node2D


@onready var core: Core = $Core

var grunt: PackedScene = preload("res://src/scenes/enemyscenes/CellCarrier.tscn")
var energy_cell: PackedScene = preload("res://src/scenes/gameplayscenes/EnergyCell.tscn")

signal game_start

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_game():
	game_start.emit()
	var enemy = grunt.instantiate()
	add_child(enemy)

func add_cell(cell_position: Vector2) -> void:
	print(cell_position)
	var cell = energy_cell.instantiate()
	cell.global_position = cell_position
	add_child.call_deferred(cell)

func _on_child_entered_tree(node: Node) -> void:
	if node is RangerPlayer:
		start_game()
	elif node is CellCarrier:
		node.carrier_death.connect(add_cell)
	elif node is EnergyCell:
		node.cell_pickup.connect(core.add_power)
