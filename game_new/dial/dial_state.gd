class_name DialState
extends RefCounted

const MAX_DIAL: float = 100.0

var dial_amount: float = 0.0:
	set = set_dial_amount
var cursor_angle: float = 0.0

var gauges: Array[Gauge] = []

func set_dial_amount(new_dial_amount: float) -> void:
	dial_amount = new_dial_amount
	cursor_angle = TAU * (dial_amount / MAX_DIAL)

func add_gauge(gauge: Gauge) -> void:
	gauge.initialize()
	gauges.append(gauge)

func remove_gauge(gauge: Gauge) -> void:
	gauges.erase(gauge)
