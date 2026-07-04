extends Node2D

@export var dial: Dial

var dial_state: DialState

func _ready() -> void:
	dial_state = dial.get_state()
	var g = Gauge.new()
	g.color = Color.from_hsv(
		randf(), 1.0, 1.0
	)
	g.start_angle = TAU * randf()
	g.width = randf_range(0.01, 0.2)
	g.lifetime = randf_range(5, 10)
	g.moves_clockwise = false
	g.move_period = randf_range(3, 10)
	g.initialize()
	dial_state.add_gauge(g)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_restart") and OS.is_debug_build():
		get_tree().reload_current_scene()
