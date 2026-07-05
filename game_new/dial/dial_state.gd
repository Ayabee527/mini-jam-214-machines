class_name DialState
extends RefCounted

signal gauge_initialized(gauge: Gauge)

const MAX_DIAL: float = 100.0

var dial_amount: float = 0.0:
	set = set_dial_amount
var cursor_angle: float = 0.0

var gauges: Array[Gauge] = []

func set_dial_amount(new_dial_amount: float) -> void:
	dial_amount = new_dial_amount
	cursor_angle = TAU * (dial_amount / MAX_DIAL)

func add_gauge(gauge: Gauge) -> void:
	gauge.initialized.connect(
		func():
			gauge_initialized.emit(gauge)
	)
	gauge.initialize()
	gauges.append(gauge)

func remove_gauge(gauge: Gauge) -> void:
	gauges.erase(gauge)

func get_occupied_slices() -> Dictionary[float, float]:
	var occupied: Dictionary[float, float] = {}
	for gauge: Gauge in gauges:
		var min_a = gauge.cur_angle - (gauge.cur_width * TAU / 2.0)
		var max_a = gauge.cur_angle + (gauge.cur_width * TAU / 2.0)
		occupied[min_a] = max_a
	return occupied
