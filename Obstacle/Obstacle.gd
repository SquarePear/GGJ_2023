extends Node2D

var bad = true

@onready var _collider = $Area2D/CollisionShape2D


func _ready():
	global_rotation = randf() * 2 * PI

	var random_scale = randf() * 0.5 + 0.5
	scale = Vector2(random_scale, random_scale)


func detect_line_collision(line_start, line_end):
	var line = Line2D.new()
	line.add_point(line_start)
	line.add_point(line_end)
	var collision = _collider.collide_shape(line, Vector2.ZERO)
	line.free()
	return collision
