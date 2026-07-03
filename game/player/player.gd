class_name Player
extends Node2D

const INPUTS = {
	"move_left": Vector2.LEFT,
	"move_right": Vector2.RIGHT,
	"move_down": Vector2.DOWN,
	"move_up": Vector2.UP,
}

@export var coll_detect_raycast: RayCast2D

var moving: bool = false

func move(dir: Vector2, move_time: float = 0.1):
	coll_detect_raycast.target_position = dir * Util.tile_size
	coll_detect_raycast.force_raycast_update()
	if not coll_detect_raycast.is_colliding():
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(
			self, "global_position", global_position + (dir * Util.tile_size), move_time
		)
		moving = true
		await tween.finished
		moving = false
