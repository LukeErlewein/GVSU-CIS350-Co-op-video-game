extends Resource
class_name Skill

@export var cooldown: float = 1.0
@export var texture: Texture2D
@export var animation_name: String

func _init(target):
	target.cooldown.max_value = cooldown
	target.texture_normal = texture
	target.timer.wait_time = cooldown

func cast_spell(target):
	if !target.is_multiplayer_authority():
		return
	print(animation_name + " casted from " + target.name)
