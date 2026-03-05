extends Node2D

##############################################
#Global Variables
##############################################
@export var enemy_scene:= preload("res://scenes/game/combat/entities/Enemy.tscn") 

var yPos = 100

var column_enemy_positions: Dictionary = {
	1: Vector2(314.0, yPos),
	2: Vector2(446.0, yPos),
	3: Vector2(574.0, yPos),
	4: Vector2(698.0, yPos),
	5: Vector2(826.0, yPos)
}
var rng = RandomNumberGenerator.new()
var randomPos = -1
var used_enemy_positions = Array([], TYPE_INT, "", null)

##############################################
#Functions
##############################################
func _on_enemy_spawn_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	randomPos = rng.randi_range(1, 5)

	print("Timer method is running...")

	if(!used_enemy_positions.has(randomPos)):
		enemy.position = column_enemy_positions[randomPos]
		used_enemy_positions.append(randomPos)
		print("used enemy positions: " + str(used_enemy_positions))
		print(str(enemy.position))
		add_child(enemy)
