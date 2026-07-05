class_name MachineDial
extends Node2D

const MAX_SHAKE_AMOUNT: float = 6.0

@export var machine_name: String = ""
@export var machine_id: GameManager.Machines = GameManager.Machines.HEAT
@export var status_gradient: Gradient
@export var radius: float = 16.0
@export var breadth: float = 4.0
@export var shadow_offset: Vector2 = Vector2.ONE * 1.0
@export var color: Color = Color.WHITE
@export var angle_offset: float = 90.0
@export var start_angle: float = 60.0
@export var end_angle: float = 300.0
@export var font_size: int = 8
@export var font_offset: Vector2 = Vector2(0, 24)
@export var shake_on_empty: bool = true
@export var shake_on_full: bool = true

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
				machine_data.broke.connect(
					func():
						var t1 = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
						t1.tween_property(
							self, "shake_amount", MAX_SHAKE_AMOUNT * 0.15, 1.0
						)
						var t2 = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
						t2.set_loops()
						t2.tween_property(
							machine_data, "status", 0.0, 1.5
						)
						t2.tween_property(
							machine_data, "status", 1.0, 1.5
						)
				)
	)
	GameManager.machine_removed.connect(
		func(machine: GameManager.Machines):
			if machine == machine_id:
				shake_amount = 0.0
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
		var col: Color = color
		if status_gradient:
			col = status_gradient.sample(machine_data.status)
		if machine_data.broken:
			col = Color.DIM_GRAY
		draw_arc(
			Vector2.ZERO, radius, deg_to_rad(start_angle + angle_offset),
			deg_to_rad(start_angle + progress + angle_offset),
			64, col,
			breadth
		)
	
	if icon:
		draw_texture(
			icon, center_icon(shadow_offset, icon), Color.BLACK
		)
		var col: Color = color
		if machine_data.broken:
			col = Color.DIM_GRAY
		draw_texture(
			icon, center_icon(Vector2.ZERO, icon), col
		)
	
	if font:
		draw_string(
			font, center_string(font_offset + shadow_offset, machine_name, font),
			machine_name, HORIZONTAL_ALIGNMENT_CENTER, -1,
			font_size, Color.BLACK
		)
		var col: Color = color
		if machine_data.broken:
			col = Color.DIM_GRAY
		draw_string(
			font, center_string(font_offset, machine_name, font),
			machine_name, HORIZONTAL_ALIGNMENT_CENTER, -1,
			font_size, col
		)

func center_icon(pos: Vector2, c_icon: Texture2D) -> Vector2:
	return pos - (c_icon.get_size() / 2.0)

func center_string(pos: Vector2, string: String, c_font: Font) -> Vector2:
	return pos - (c_font.get_string_size(string, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size) / 2.0)

func reshake() -> void:
	var power: int = 2
	if machine_data:
		if not machine_data.broken:
			if shake_on_empty and shake_on_full:
				shake_amount = pow(2, 2 * power) * MAX_SHAKE_AMOUNT * pow(machine_data.status - 0.5, 2 * power)
			elif shake_on_empty and not shake_on_full:
				shake_amount = 1 - pow(machine_data.status, 2 * power)
			elif shake_on_full and not shake_on_empty:
				shake_amount = pow(machine_data.status, 2 * power)
	
	shake_offset = Vector2(
		randf_range(-shake_amount, shake_amount),
		randf_range(-shake_amount, shake_amount)
	)
	
	shake_timer.start()

func _on_shake_timer_timeout() -> void:
	reshake()
