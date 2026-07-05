class_name MachineDial
extends Node2D

const MAX_SHAKE_AMOUNT: float = 8.0

@export var machine_name: String = ""
@export var machine_id: GameManager.Machines = GameManager.Machines.HEAT
@export var radius: float = 16.0
@export var breadth: float = 4.0
@export var shadow_offset: Vector2 = Vector2.ONE * 1.0
@export var color: Color = Color.WHITE
@export var angle_offset: float = 90.0
@export var start_angle: float = 60.0
@export var end_angle: float = 300.0
@export var font_size: int = 8
@export var font_offset: Vector2 = Vector2(0, 24)

@export var icon: Texture2D
@export var font: Font
@export_group("Inner Dependencies")
@export var shake_timer: Timer

var machine_data: MachineData

var shake_amount: float = 0.0
var shake_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	GameManager.machine_added.connect(
		func(machine: GameManager.Machines):
			if machine == machine_id:
				machine_data = GameManager.get_machine_data(machine)
	)
	GameManager.machine_removed.connect(
		func(machine: GameManager.Machines):
			if machine == machine_id:
				machine_data = null
	)
	
	shake_timer.start()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not machine_data:
		return
	
	draw_set_transform(shake_offset)
	draw_arc(
		Vector2.ZERO, radius, deg_to_rad(start_angle + angle_offset),
		deg_to_rad(end_angle + angle_offset), 64,
		Color(0,0,0,0.4), breadth
	)
	
	if machine_data:
		var progress: float = machine_data.status * (end_angle - start_angle)
		draw_arc(
			shadow_offset, radius, deg_to_rad(start_angle + angle_offset),
			deg_to_rad(start_angle + progress + angle_offset),
			64, Color.BLACK, breadth
		)
		draw_arc(
			Vector2.ZERO, radius, deg_to_rad(start_angle + angle_offset),
			deg_to_rad(start_angle + progress + angle_offset),
			64, color, breadth
		)
	
	if icon:
		draw_texture(
			icon, center_icon(shadow_offset, icon), Color.BLACK
		)
		draw_texture(
			icon, center_icon(Vector2.ZERO, icon), color
		)
	
	if font:
		draw_string(
			font, center_string(font_offset + shadow_offset, machine_name, font),
			machine_name, HORIZONTAL_ALIGNMENT_CENTER, -1,
			font_size, Color.BLACK
		)
		draw_string(
			font, center_string(font_offset, machine_name, font),
			machine_name, HORIZONTAL_ALIGNMENT_CENTER, -1,
			font_size, color
		)

func center_icon(pos: Vector2, c_icon: Texture2D) -> Vector2:
	return pos - (c_icon.get_size() / 2.0)

func center_string(pos: Vector2, string: String, c_font: Font) -> Vector2:
	return pos - (c_font.get_string_size(string, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size) / 2.0)

func reshake() -> void:
	shake_amount = 0.0
	var power: int = 2
	if machine_data:
		shake_amount = pow(2, 2 * power) * MAX_SHAKE_AMOUNT * pow(machine_data.status - 0.5, 2 * power)
	
	shake_offset = Vector2(
		randf_range(-shake_amount, shake_amount),
		randf_range(-shake_amount, shake_amount)
	)
	
	shake_timer.start(
		lerp(1.0, 0.1, shake_amount / MAX_SHAKE_AMOUNT)
	)

func _on_shake_timer_timeout() -> void:
	reshake()
