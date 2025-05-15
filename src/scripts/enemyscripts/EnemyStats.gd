class_name EnemyStats extends Resource

@export var health: float
@export var speed: float
@export var texture: Texture2D
@export_enum("PLAYERS", "CORE", "ALL") var target: String
@export_enum("GRUNT","CELL_CARRIER","SPEEDER","BOSS","HEALER","ASSASSIN") var enemyType: String
