extends Node2D

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
var used_positions = Array([], TYPE_INT, "", null)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_enemy_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	var randomPos = rng.randi_range(1, 6)
	
	print("Timer method running...")
	
	if(!used_positions.has(randomPos)):
		enemy.position = column_enemy_positions[randomPos]
		used_positions.append(randomPos)
		print("used enemy positions: " + str(used_positions))
		add_child(enemy)
	
	
