extends Node2D

var grunt: PackedScene = preload("res://src/scenes/enemyscenes/Grunt.tscn")
signal game_start
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_game():
	game_start.emit()
	var enemy = grunt.instantiate()
	add_child(enemy)


func _on_child_entered_tree(node: Node) -> void:
	if node is RangerPlayer:
		start_game()
