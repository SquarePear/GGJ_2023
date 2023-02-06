extends Control

@onready var _lives_display = $CanvasLayer/Lives


func _update_lives(_lives):
	_lives_display.get_child(_lives_display.get_child_count() - 1).queue_free()
