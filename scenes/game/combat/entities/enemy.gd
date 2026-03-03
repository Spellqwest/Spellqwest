extends Node2D

var rng = RandomNumberGenerator.new()
var count = 0

var column_positions: Dictionary = {
	1: Vector2(100, 0),
	2: Vector2(200, 0),
	3: Vector2(300, 0),
	4: Vector2(400, 0),
	5: Vector2(500, 0),
	6: Vector2(600, 0)
}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
	#count += 1
	#if(count >= 500):
		#count = 0
		#changePos()
	
	
func changePos() -> void:
	var randomPos = rng.randi_range(1, 6)
	position = column_positions[randomPos]
	print("enemy pos changed to: " + str(column_positions[randomPos].x) + ", " + str(column_positions[randomPos].y))	
