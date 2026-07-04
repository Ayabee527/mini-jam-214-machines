extends Node

const TICK_TIME: float = 0.1

signal ticked()

var ticking: bool = true
var time: float = 0

func _process(delta: float) -> void:
	if ticking:
		time += delta
		if time > TICK_TIME:
			time = fposmod(time, TICK_TIME)
			ticked.emit()
