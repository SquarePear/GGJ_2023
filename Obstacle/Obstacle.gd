class_name Obstacle
extends Node2D

var _bad = true

@onready var _collider = $Area2D/CollisionShape2D
@onready var _sprite = $Sprite2D


func _ready():
	global_rotation = randf() * 2 * PI

	var random_scale = randf() * 0.5 + 0.5
	scale = Vector2(random_scale, random_scale)

	_bad = randf() < 0.5

	if _bad:
		_sprite.modulate = Color(1.0, 0.2, 0.2)
	else:
		_sprite.modulate = Color(0.2, 1.0, 0.2)


func detect_line_collision(line_start, line_end):
	var line = Line2D.new()
	line.add_point(line_start)
	line.add_point(line_end)
	var collision = _collider.collide_shape(line, Vector2.ZERO)
	line.free()
	return collision


func is_bad():
	return _bad
