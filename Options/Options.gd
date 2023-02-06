extends Control


func _on_fullscreen_button_pressed():
	var current_mode := DisplayServer.window_get_mode()

	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_mute_button_pressed():
	pass


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://MainMenu/MainMenu.tscn")
