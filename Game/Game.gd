extends Node2D

@onready var _obstacles = $Obstacles


func _ready():
	_initialize_obstacles()


func _process(_delta):
	pass


func _physics_process(_delta):
	pass


func _initialize_obstacles():
	for i in 25:
		var obstacle = preload("res://Obstacle/Obstacle.tscn").instantiate()
		obstacle.position = Vector2(
			randf_range(0, get_viewport_rect().size.x), randf_range(0, get_viewport_rect().size.y)
		)
		_obstacles.add_child(obstacle)
