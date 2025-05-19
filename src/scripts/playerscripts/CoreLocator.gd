extends TextureRect

var player_node: Node2D
var core_node: Core

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	player_node = get_parent().get_parent()
	core_node = player_node.get_parent().get_node("Core")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_multiplayer_authority(): show()
	if not core_node or not player_node:
		return
	# Compute direction from player to core using global world positions
	var center_of_map = Vector2(576, 324)  # Change if your map’s center isn't exactly (0, 0)
	var player_pos = player_node.global_position
	var direction = (center_of_map - player_pos).normalized()
	# Calculate the angle and apply it to the UI arrow
	rotation = direction.angle()  # Add PI/2 only if the arrow image points right
