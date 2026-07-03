class_name Player
extends Node2D

const INPUTS = {
	"move_left": Vector2.LEFT,
	"move_right": Vector2.RIGHT,
	"move_down": Vector2.DOWN,
	"move_up": Vector2.UP,
}

@export var coll_detect_raycast: RayCast2D
@export var sprite: Sprite2D

var moving: bool = false

func _ready() -> void:
	pass

func move(dir: Vector2, move_time: float = 0.1):
	sprite.global_rotation = Vector2.RIGHT.angle_to(dir)
	coll_detect_raycast.target_position = dir * Util.tile_size
	coll_detect_raycast.force_raycast_update()
	if not coll_detect_raycast.is_colliding():
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.set_parallel()
		tween.tween_property(
			self, "global_position", global_position + (dir * Util.tile_size), move_time
		)
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(
			sprite, "scale:y", 1, move_time
		).from(0.25)
		moving = true
		await tween.finished
		moving = false
	else:
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.set_parallel()
		tween.tween_property(
			sprite, "offset", Vector2.ZERO, move_time
		).from(Vector2.RIGHT * Util.tile_size * 0.25)
		moving = true
		await tween.finished
		moving = false
