extends PlayerState

@export var walk_speed: float = 0.1

func physics_update(_delta: float) -> void:
	if player.moving:
		return
	
	if Input.is_action_pressed("move_left"):
		player.move(Vector2.LEFT, walk_speed)
	elif Input.is_action_pressed("move_right"):
		player.move(Vector2.RIGHT, walk_speed)
	elif Input.is_action_pressed("move_up"):
		player.move(Vector2.UP, walk_speed)
	elif Input.is_action_pressed("move_down"):
		player.move(Vector2.DOWN, walk_speed)
