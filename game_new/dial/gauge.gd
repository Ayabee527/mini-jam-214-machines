class_name Gauge
extends RefCounted

var id: GameManager.GaugeID = GameManager.GaugeID.START_GAME
var color: Color = Color.WHITE
var start_angle: float = 0.0
var width: float = 0.05
var lifetime: float = 5.0
var decay_over_lifetime: bool = true
var moves_clockwise: bool = true
var move_period: float = 0

var life_left: float = 0.0
var cur_width: float = 0.0
var cur_angle: float = 0.0

func initialize() -> void:
	cur_angle = start_angle
	cur_width = width
	life_left = lifetime

func overlapping_ranges(left: float, right: float) -> bool:
	var self_left: float = cur_angle - (cur_width * TAU / 2.0)
	var self_right: float = cur_angle + (cur_width * TAU / 2.0)
	
	return left < self_right and right > self_left
