extends Node2D

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_restart") and OS.is_debug_build():
		get_tree().reload_current_scene()
