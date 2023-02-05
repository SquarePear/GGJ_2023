extends Node2D

var _root = null
var _points: PackedVector2Array = []
var _previous_roots := []

@onready var _roots = $Roots
@onready var _obstacles = $Obstacles
@onready var _root_tracker = $RootTracker
@onready var _audio_player = $AudioStreamPlayer


func _ready():
	_initialize_root()
	_initialize_obstacles()

	_root.set_tip_position(Vector2(get_viewport_rect().size.x / 2, 128), PI / 2, false)


func _physics_process(_delta):
	if _root or _points.size() == 0:
		return

	var final_index = _points.size() - 1

	_root_tracker.global_position = _points[final_index]
	_root_tracker.global_rotation = (_points[final_index] - _points[final_index - 1]).angle()

	_points.remove_at(final_index)

	if _points.size() == 0:
		_initialize_root()
		_root.set_tip_position(_root_tracker.global_position, _root_tracker.global_rotation)
		_root_tracker.visible = false


func _input(event):
	if _root or _points.size() == 0:
		return

	if event is InputEventMouseButton and event.is_pressed():
		_initialize_root()
		_root.set_tip_position(_root_tracker.global_position, _root_tracker.global_rotation)
		_root_tracker.visible = false


func _initialize_obstacles():
	for i in 25:
		var obstacle = preload("res://Obstacle/Obstacle.tscn").instantiate()
		obstacle.position = Vector2(
			randf_range(0, get_viewport_rect().size.x), randf_range(192, get_viewport_rect().size.y)
		)
		_obstacles.add_child(obstacle)


func _initialize_root():
	_root = preload("res://Root/Root.tscn").instantiate()

	_root.set_previous_roots(_previous_roots)

	_root.connect("hit_obstacle", _on_root_hit_obstacle)
	_root.connect("reached_goal", _on_root_reached_goal)

	_roots.add_child(_root)


func _check_game_over():
	var game_over := true

	for obstacle in _obstacles.get_children():
		if obstacle.is_bad():
			continue

		game_over = false
		break

	if not game_over:
		return

	_points.clear()
	_root_tracker.visible = false


func _save_screenshot():
	# Wait two frames to make sure the obstacles are gone
	await get_tree().process_frame
	await get_tree().process_frame

	var image = get_viewport().get_texture().get_image()
	image.save_png("downloads://screenshot.png")


func _on_root_hit_obstacle(obstacle):
	# Slighly randomize pitch and volume
	_audio_player.pitch_scale = randf_range(0.9, 1.1)
	_audio_player.volume_db = randf_range(-3, 3)

	if obstacle.is_bad():
		_audio_player.stream = preload("res://Game/Bump.ogg")
		_audio_player.play()
	else:
		_audio_player.stream = preload("res://Game/Collect.ogg")
		_audio_player.play()


func _on_root_reached_goal(obstacle, points):
	_root = null
	_points += points
	_previous_roots.append(points)
	_root_tracker.visible = true

	_obstacles.remove_child(obstacle)
	obstacle.queue_free()

	_check_game_over()
