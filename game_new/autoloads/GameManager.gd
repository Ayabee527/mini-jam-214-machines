extends Node

signal machine_added(machine: Machines)
signal machine_removed(machine: Machines)
signal machine_emptied(machine: Machines)
signal machine_filled(machine: Machines)
signal machine_broke(machine: Machines)

enum GaugeID {
	START_GAME,
	TOGGLE_HEAT,
	REDUCE_RADIATION,
}

enum Machines {
	HEAT,
	PRESSURE,
	POWER,
	CLOCK,
	SIGNAL,
	RADIATION,
}

var datas: Dictionary[Machines, MachineData] = {
	Machines.HEAT: null,
	Machines.PRESSURE: null,
	Machines.POWER: null,
	Machines.CLOCK: null,
	Machines.SIGNAL: null,
	Machines.RADIATION: null,
}

var colors: Dictionary[Machines, Color] = {
	Machines.HEAT: Color(0.725, 0.306, 0.0, 1.0),
	Machines.PRESSURE: Color(0.541, 0.714, 0.761, 1.0),
	Machines.POWER: Color(0.824, 0.741, 0.176, 1.0),
	Machines.CLOCK: Color(0.49, 0.455, 0.29, 1.0),
	Machines.SIGNAL: Color(0.992, 0.255, 0.918, 1.0),
	Machines.RADIATION: Color(0.0, 0.882, 0.306, 1.0),
}

func _process(delta: float) -> void:
	for data: MachineData in datas.values():
		if data == null:
			continue
		if data.broken:
			continue
		
		data.status -= data.status_change_rate * delta

func add_machine(machine: Machines) -> void:
	if not datas.has(machine):
		return
	
	if datas[machine] == null:
		var data: MachineData = MachineData.new()
		
		match machine:
			Machines.HEAT:
				data.status_change_rate = -0.025
			Machines.RADIATION:
				data.status = 0
				data.status_change_rate = -0.075
		
		datas[machine] = data
		machine_added.emit(machine)
		
		data.emptied.connect(
			func():
				machine_emptied.emit(machine)
		)
		data.filled.connect(
			func():
				machine_filled.emit(machine)
		)
		data.broke.connect(
			func():
				machine_broke.emit(machine)
		)

func remove_machine(machine: Machines) -> void:
	if datas[machine] != null:
		datas[machine] = null
		machine_removed.emit(machine)

func get_machine_data(machine: Machines) -> MachineData:
	return datas[machine]

func get_locked_machines() -> Array[Machines]:
	var locked: Array[Machines] = []
	
	for machine in datas:
		if datas[machine] == null:
			locked.append(machine)
	
	return locked

func get_unlocked_machines() -> Array[Machines]:
	var unlocked: Array[Machines] = []
	
	for machine in datas:
		if datas[machine] != null:
			unlocked.append(machine)
	
	return unlocked
