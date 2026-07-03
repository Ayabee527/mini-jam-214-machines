class_name CWobble
extends Node

@export var target: Node2D = null
@export var active: bool = false:
	set = set_active
@export var max_rotation: float = 25.0
@export var frequency: float = 25.0
@export var reset_time: float = 0.15

var time: float = 0.0
var wobble: float = 0.0
var wobble_decay: float = 0.0

func set_active(new_active: bool) -> void:
	active = new_active
	if not active:
		time = 0
		wobble_decay = abs(wobble) / reset_time

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	
	if active:
		time = fposmod(time + delta, TAU)
		wobble = sin(frequency * time) * max_rotation
	else:
		wobble = move_toward(wobble, 0.0, wobble_decay * delta)
	
	target.rotation_degrees = wobble
