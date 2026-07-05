class_name MachineData
extends RefCounted

signal emptied()
signal filled()

var status: float = 0.5
var broken: bool = false

func set_status(new_status: float) -> void:
	status = clampf(new_status, 0.0, 1.0)
	if status == 0.0:
		emptied.emit()
	if status == 1.0:
		filled.emit()
