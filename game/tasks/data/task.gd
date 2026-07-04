class_name Task
extends Resource

signal failed()

@export var fail_gradient: Gradient
@export var min_fail: float = 0
@export var max_fail: float = 0

var fail_progress: float = 0.0
