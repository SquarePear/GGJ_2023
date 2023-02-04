extends Node2D

@onready var _roots = $Roots
@onready var _obstacles = $Obstacles


func _ready():
	_initialize_root()
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


func _initialize_root():
	var root = preload("res://Root/Root.tscn").instantiate()

	root.connect("reached_goal", _on_root_reached_goal)

	_roots.add_child(root)

	return root


func _on_root_reached_goal(points):
	var root = _initialize_root()
	# get position of middle point
	var middle_point = points[floor(points.size() / 2)]
	print(middle_point)
	root.set_position(middle_point)
