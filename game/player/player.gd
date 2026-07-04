class_name Player
extends Node2D

@export var walk_speed: float = 0.1

@export var coll_detect_raycast: RayCast2D
@export var sprite: Sprite2D

var moving: bool = false
var walks: int = 0

func _physics_process(_delta: float) -> void:
	if moving:
		return
	
	if Input.is_action_pressed("move_left"):
		move(Vector2.LEFT, walk_speed)
	elif Input.is_action_pressed("move_right"):
		move(Vector2.RIGHT, walk_speed)
	elif Input.is_action_pressed("move_up"):
		move(Vector2.UP, walk_speed)
	elif Input.is_action_pressed("move_down"):
		move(Vector2.DOWN, walk_speed)

func move(dir: Vector2, move_time: float = 0.1):
	coll_detect_raycast.target_position = dir * Util.CELL_SIZE
	coll_detect_raycast.force_raycast_update()
	if not coll_detect_raycast.is_colliding():
		var tilt: float = 30.0
		if walks % 2 == 0:
			tilt *= -1
		var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.set_parallel()
		tween.tween_property(
			self, "global_position", global_position + (dir * Util.CELL_SIZE), move_time
		)
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(
			sprite, "global_rotation_degrees", 0, move_time
		).from(tilt)
		moving = true
		walks += 1
		await tween.finished
		moving = false
	else:
		var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(
			sprite, "offset", Vector2.ZERO, move_time
		).from(dir * Util.CELL_SIZE * 0.5)
		moving = true
		await tween.finished
		moving = false
