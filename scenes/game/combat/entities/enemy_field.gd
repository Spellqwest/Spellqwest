extends Node2D

##############################################
#Global Variables
##############################################
@export var enemy_scene:= preload("res://scenes/game/combat/entities/Enemy.tscn") 

var yPosWave1 = 100

var enemy_waves: Dictionary = {
	1: Vector2(314.0, yPosWave1),
	2: Vector2(446.0, yPosWave1),
	3: Vector2(574.0, yPosWave1),
	4: Vector2(698.0, yPosWave1),
	5: Vector2(826.0, yPosWave1)
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

	if(!used_enemy_positions.has(randomPos)):
		enemy.position = enemy_waves[randomPos]
		used_enemy_positions.append(randomPos)
		print("used enemy positions: " + str(used_enemy_positions))
		print(str(enemy.position))
		add_child(enemy)
