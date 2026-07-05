class_name MachineHandler
extends Node2D

@export_group("Timers")
@export var heat_timer: Timer
@export var pressure_timer: Timer
@export var power_timer: Timer
@export var clock_timer: Timer
@export var signal_timer: Timer
@export var radiation_timer: Timer

@onready var timers: Dictionary[GameManager.Machines, Timer] = {
	GameManager.Machines.HEAT: heat_timer,
	GameManager.Machines.PRESSURE: pressure_timer,
	GameManager.Machines.POWER: power_timer,
	GameManager.Machines.CLOCK: clock_timer,
	GameManager.Machines.SIGNAL: signal_timer,
	GameManager.Machines.RADIATION: radiation_timer,
}

func _ready() -> void:
	GameManager.machine_added.connect(on_machine_added)

func on_machine_added(machine: GameManager.Machines) -> void:
	timers[machine].start()
	
	match machine:
		GameManager.Machines.HEAT:
			pass

func _on_dial_gauge_confirmed(id: GameManager.GaugeID) -> void:
	match id:
		pass
