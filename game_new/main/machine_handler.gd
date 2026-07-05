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
@export var queue_timer: Timer

var queue: Array[GameManager.Machines] = []
var unlock_amount: int = 1

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
	#timers[machine].start()
	if queue_timer.is_stopped():
		queue_timer.start()
	
	match machine:
		GameManager.Machines.HEAT:
			prompt_machine(GameManager.Machines.HEAT)
		GameManager.Machines.RADIATION:
			prompt_machine(GameManager.Machines.RADIATION)

func on_machine_emptied(machine: GameManager.Machines) -> void:
	match machine:
		GameManager.Machines.HEAT:
			GameManager.datas[machine].broken = true

func on_machine_filled(machine: GameManager.Machines) -> void:
	match machine:
		GameManager.Machines.HEAT:
			GameManager.datas[machine].broken = true
		GameManager.Machines.RADIATION:
			GameManager.datas[machine].broken = true

func on_machine_broke(machine: GameManager.Machines) -> void:
	timers[machine].stop()
	
	match machine:
		GameManager.Machines.HEAT:
			for gauge: Gauge in dial_state.gauges:
				if gauge.id == GameManager.GaugeID.TOGGLE_HEAT:
					gauge.kill()
		GameManager.Machines.RADIATION:
			for gauge: Gauge in dial_state.gauges:
				if gauge.id == GameManager.GaugeID.REDUCE_RADIATION:
					gauge.kill()

func prompt_machine(machine: GameManager.Machines) -> void:
	match machine:
		GameManager.Machines.HEAT:
			var prompt = Gauge.new()
			
			prompt.color = GameManager.colors[machine]
			#prompt.lifetime = heat_timer.wait_time * 0.75
			prompt.lifetime = 4.5
			prompt.start_angle = Util.get_random_unoccupied_angle(
				dial_state.get_occupied_slices(), 0.05
			)
			if prompt.start_angle == INF:
				print("Couldn't fit!")
				prompt.start_angle = randf() * TAU
			prompt.id = GameManager.GaugeID.TOGGLE_HEAT
			prompt.width = 0.05
			
			dial_state.add_gauge(prompt)
		GameManager.Machines.RADIATION:
			GameManager.datas[machine].status_change_rate = -0.075
			var start_ang: float = randf() * TAU
			for i in range(3):
				var ang = wrapf(
					start_ang + (i * 2 * PI / 3),
					0, TAU
				)
				
				var prompt = Gauge.new()
				
				prompt.color = GameManager.colors[machine]
				#prompt.lifetime = radiation_timer.wait_time * 0.5
				prompt.lifetime = 4.0
				prompt.start_angle = ang
				prompt.id = GameManager.GaugeID.REDUCE_RADIATION
				prompt.width = 0.15
				
				dial_state.add_gauge(prompt)

func advance_queue() -> void:
	if queue.is_empty():
		queue = GameManager.get_unlocked_machines()
		unlock_amount = queue.size()
	
	prompt_machine( queue.pop_back() )
	queue_timer.start(
		lerp(10.0, 5.0, float(unlock_amount) / GameManager.datas.size())
	)

func _on_dial_gauge_confirmed(id: GameManager.GaugeID) -> void:
	match id:
		GameManager.GaugeID.TOGGLE_HEAT:
			GameManager.datas[GameManager.Machines.HEAT].status_change_rate *= -1
		GameManager.GaugeID.REDUCE_RADIATION:
			GameManager.datas[GameManager.Machines.RADIATION].status_change_rate += 0.0375


func _on_heat_timer_timeout() -> void:
	prompt_machine(GameManager.Machines.HEAT)


func _on_pressure_timer_timeout() -> void:
	prompt_machine(GameManager.Machines.PRESSURE)


func _on_power_timer_timeout() -> void:
	prompt_machine(GameManager.Machines.POWER)


func _on_clock_timer_timeout() -> void:
	prompt_machine(GameManager.Machines.CLOCK)


func _on_signal_timer_timeout() -> void:
	prompt_machine(GameManager.Machines.SIGNAL)


func _on_radiation_timer_timeout() -> void:
	prompt_machine(GameManager.Machines.RADIATION)

func _on_queue_timer_timeout() -> void:
	advance_queue()
