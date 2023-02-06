extends Control


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Game/Game.tscn")


func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://Options/Options.tscn")


func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://Credits/Credits.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
