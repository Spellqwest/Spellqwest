extends Node2D

##############################################
#Global Variables
##############################################
@export var enemy_scene:= preload("res://scenes/game/combat/entities/Enemy.tscn") 

var column_enemy_positions: Dictionary = {
	1: Vector2(100, 0),
	2: Vector2(200, 0),
	3: Vector2(300, 0),
	4: Vector2(400, 0),
	5: Vector2(500, 0),
	6: Vector2(600, 0)
}
var rng = RandomNumberGenerator.new()
var randomPos = -1
var used_enemy_positions = Array([], TYPE_INT, "", null)

##############################################
#Functions
##############################################
func _on_enemy_spawn_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	randomPos = rng.randi_range(1, 6)

	print("Timer method is running...")

	if(!used_enemy_positions.has(randomPos)):
		enemy.position = column_enemy_positions[randomPos]
		used_enemy_positions.append(randomPos)
		print("used enemy positions: " + str(used_enemy_positions))
		add_child(enemy)
