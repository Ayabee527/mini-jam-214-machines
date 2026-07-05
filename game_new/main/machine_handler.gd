class_name MachineHandler
extends Node2D

var dial_state: DialState

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
	GameManager.machine_emptied.connect(on_machine_emptied)
	GameManager.machine_filled.connect(on_machine_filled)
	GameManager.machine_broke.connect(on_machine_broke)

func on_machine_added(machine: GameManager.Machines) -> void:
	timers[machine].start()
	
	match machine:
		GameManager.Machines.HEAT:
			prompt_machine(GameManager.Machines.HEAT)

func on_machine_emptied(machine: GameManager.Machines) -> void:
	match machine:
		GameManager.Machines.HEAT:
			GameManager.datas[machine].broken = true
			heat_timer.stop()

func on_machine_filled(machine: GameManager.Machines) -> void:
	match machine:
		GameManager.Machines.HEAT:
			GameManager.datas[machine].broken = true
			heat_timer.stop()

func on_machine_broke(machine: GameManager.Machines) -> void:
	timers[machine].stop()
	
	match machine:
		GameManager.Machines.HEAT:
			for gauge: Gauge in dial_state.gauges:
				if gauge.id == GameManager.GaugeID.TOGGLE_HEAT:
					gauge.lifetime = 0.25
					gauge.life_left = gauge.lifetime

func prompt_machine(machine: GameManager.Machines) -> void:
	match machine:
		GameManager.Machines.HEAT:
			var prompt = Gauge.new()
			
			prompt.color = GameManager.colors[machine]
			prompt.lifetime = heat_timer.wait_time * 0.75
			prompt.start_angle = randf() * TAU
			prompt.id = GameManager.GaugeID.TOGGLE_HEAT
			
			dial_state.add_gauge(prompt)

func _on_dial_gauge_confirmed(id: GameManager.GaugeID) -> void:
	match id:
		GameManager.GaugeID.TOGGLE_HEAT:
			GameManager.datas[GameManager.Machines.HEAT].status_change_rate *= -1


func _on_heat_timer_timeout() -> void:
	prompt_machine(GameManager.Machines.HEAT)


func _on_pressure_timer_timeout() -> void:
	prompt_machine(GameManager.Machines.PRESSURE)
