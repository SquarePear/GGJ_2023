class_name Root
extends Node2D

signal reached_goal(points)

var _noise = FastNoiseLite.new()
var _intersecting = false
var _to_die = 0

@onready var _line: Line2D = $Line2D
@onready var _line_segment_timer = $LineSegmentTimer
@onready var _root_tip = $RootTip


func _ready():
	_initialize_noise()
	_initialize_line()

	_root_tip.global_position = Vector2(get_viewport_rect().size.x / 2, 64)
	_root_tip.global_rotation = PI / 2


func _process(delta):
	_move_root_tip(delta)
	_update_line_root_tip()


func _physics_process(_delta):
	if _to_die > 0:
		_step_death()
		return


func _initialize_noise():
	randomize()
	_noise.seed = randi()
	_noise.fractal_octaves = 1
	_noise.frequency = 1.0 / 500.0


func _initialize_line():
	_line.add_point(_root_tip.global_position)

	_line_segment_timer.connect("timeout", _add_point)
	_line_segment_timer.start()


func _add_point():
	if _intersecting:
		return

	_line.add_point(_root_tip.global_position)


func _move_root_tip(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_delta = (mouse_pos - _root_tip.global_position).normalized()
	var mouse_angle = mouse_delta.angle()

	# Rotate towards mouse
	var angle = _root_tip.global_rotation
	var angle_delta = angle - mouse_angle

	# Fixes angle snapping
	if angle_delta > PI:
		angle_delta -= 2 * PI
	elif angle_delta < -PI:
		angle_delta += 2 * PI

	_root_tip.global_rotation = angle - angle_delta * delta * 5
	_root_tip.global_rotation += (
		_noise.get_noise_2d(_root_tip.global_position.x, _root_tip.global_position.y) * delta * 5
	)

	_root_tip.global_position += Vector2(cos(angle), sin(angle)) * delta * 250


func _update_line_root_tip():
	if _to_die > 0:
		return

	if _line.get_point_count() < 1 or _intersecting:
		return

	var intersection = _detect_intersection()

	if intersection:
		_line.set_point_position(_line.get_point_count() - 1, intersection)
		_intersecting = true
		return

	# Set the last point to the root's position
	_line.set_point_position(_line.get_point_count() - 1, _root_tip.global_position)


func _detect_intersection():
	var point: Vector2 = _root_tip.global_position
	var points := _line.get_points()

	if points.size() <= 4:
		return

	var last_usable_point := points[points.size() - 2]

	for i in range(points.size() - 4):
		var intersection := Geometry2D.segment_intersects_segment(
			last_usable_point, point, points[i], points[i + 1]
		)

		if intersection:
			_to_die = points.size() - i - 1
			return intersection

	return null


func _step_death():
	if _line.get_point_count() <= 2:
		_to_die = 0
		_restart(_line.get_points())
		return

	_to_die -= 1
	_line.remove_point(_line.get_point_count() - 1)

	if _to_die == 0:
		_restart(_line.get_points())


func _restart(points: Array):
	# Set rotation based on last two points
	var last_point = points[points.size() - 1]
	var second_last_point = points[points.size() - 2]
	var delta = (last_point - second_last_point).normalized()
	var angle = delta.angle()

	_root_tip.global_position = last_point
	_root_tip.global_rotation = angle
	_intersecting = false


func set_position(position: Vector2):
	_root_tip.global_position = position


func get_position() -> Vector2:
	return _root_tip.global_position


func get_last_postion() -> Vector2:
	return _line.get_point_position(_line.get_point_count() - 2)


func _on_root_tip_area_entered(area):
	var obstacle = area.get_parent() as Obstacle

	if not obstacle is Obstacle:
		return

	if obstacle.is_bad():
		_to_die = 24
		_intersecting = true
	else:
		set_process(false)
		set_physics_process(false)
		self.emit_signal("reached_goal", _line.get_points())
