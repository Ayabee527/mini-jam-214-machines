class_name MachineData
extends RefCounted

signal emptied()
signal filled()
signal broke()

var status_change_rate: float = 0.1
var status: float = 0.5:
	set = set_status
var broken: bool = false:
	set = set_broken

func set_status(new_status: float) -> void:
	status = clampf(new_status, 0.0, 1.0)
	if status == 0.0:
		emptied.emit()
	if status == 1.0:
		filled.emit()

func set_broken(new_broken: bool) -> void:
	if broken == new_broken:
		return
	
	broken = new_broken
	if broken:
		broke.emit()
