class_name Dial
extends Node2D

@export var clockwise: bool = true
@export var cursor_paused: bool = false
@export var period: float = 4.0
@export var stun_time: float = 0.2

@export_group("Graphics")
@export var radius: float = 60.0
@export var breadth: float = 4.0
@export_subgroup("Gauges", "gauge")
@export var gauge_sheath: float = 2.0
@export var gauge_outline: float = 2.0
@export_subgroup("Cursor", "cursor")
@export_range(0.0, 0.5, 0.005) var cursor_half_width: float = 0.01
@export var cursor_sheath: float = 4.0
@export var cursor_outline: float = 4.0

var state: DialState

var cursor_length: float = 0.0
var cursor_radius: float = 0.01
var cursor_color: Color = Color.WHITE

func _ready() -> void:
	state = DialState.new()
	
	cursor_length = breadth + cursor_sheath
	cursor_radius = cursor_half_width * TAU

func _process(delta: float) -> void:
	update_cursor(delta)
	update_gauges(delta)
	
	queue_redraw()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("confirm"):
		confirm_cursor()

func _draw() -> void:
	# Draws dial ring
	draw_circle(
		Vector2.ZERO, radius,
		Color("191919ff"), false, breadth
	)
	
	draw_gauges()
	draw_cursor()

func draw_cursor() -> void:
	var cursor_outline_radius: float = cursor_radius + (cursor_outline / radius)
	draw_arc(
		Vector2.ZERO, radius,
		state.cursor_angle - (cursor_outline_radius / 2.0), state.cursor_angle + (cursor_outline_radius / 2.0),
		4, Color.BLACK, cursor_length + cursor_outline
	)
	draw_arc(
		Vector2.ZERO, radius,
		state.cursor_angle - (cursor_radius / 2.0), state.cursor_angle + (cursor_radius / 2.0),
		4, cursor_color, cursor_length
	)

func draw_gauges() -> void:
	for gauge: Gauge in state.gauges:
		draw_arc(
			Vector2.ZERO, radius,
			gauge.cur_angle - (gauge.cur_width * TAU / 2.0) - (gauge_outline / radius),
			gauge.cur_angle + (gauge.cur_width * TAU / 2.0) + (gauge_outline / radius),
			64, Color.BLACK,
			breadth + gauge_sheath + gauge_outline
		)
		draw_arc(
			Vector2.ZERO, radius,
			gauge.cur_angle - (gauge.cur_width * TAU / 2.0),
			gauge.cur_angle + (gauge.cur_width * TAU / 2.0),
			max(4, 64 * gauge.cur_width), gauge.color,
			breadth + gauge_sheath
		)

func get_state() -> DialState:
	return state

func update_cursor(delta: float) -> void:
	if not cursor_paused:
		if clockwise:
			state.dial_amount += (state.MAX_DIAL / period) * delta
		else:
			state.dial_amount -= (state.MAX_DIAL / period) * delta
		state.dial_amount = fposmod(state.dial_amount, state.MAX_DIAL)

func update_gauges(delta: float) -> void:
	var expired_gauges: Array[Gauge] = []
	for gauge: Gauge in state.gauges:
		if gauge.move_period != 0:
			var a_speed = TAU / period
			if not gauge.moves_clockwise:
				a_speed *= -1
			gauge.cur_angle += a_speed * delta
			gauge.cur_angle = fposmod(gauge.cur_angle, TAU)
		
		if gauge.lifetime > 0:
			gauge.life_left -= delta
			if gauge.decay_over_lifetime:
				gauge.cur_width = lerpf(0.0, gauge.width, gauge.life_left / gauge.lifetime)
			
			if gauge.life_left < 0:
				expired_gauges.append(gauge)
	
	for gauge: Gauge in expired_gauges:
		state.remove_gauge(gauge)

func squish_cursor(squish_factor: float, squish_time: float, inverted: bool = false) -> void:
	if inverted:
		squish_factor = 1 / squish_factor
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	tween.tween_property(
		self, "cursor_radius", cursor_half_width * TAU, squish_time
	).from(cursor_radius / squish_factor)
	tween.tween_property(
		self, "cursor_length", breadth + cursor_sheath, squish_time
	).from((breadth * squish_factor) + cursor_sheath)

func stun_cursor() -> void:
	squish_cursor(4.0, stun_time)
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(
		self, "cursor_color", Color.WHITE, stun_time
	).from(Color.RED)
	cursor_paused = true
	await tween.finished
	cursor_paused = false

func check_gauged() -> Gauge:
	for gauge: Gauge in state.gauges:
		var overlapping: bool = gauge.overlapping_ranges(
			state.cursor_angle - cursor_radius - (cursor_outline / radius),
			state.cursor_angle + cursor_radius + (cursor_outline / radius)
		)
		if overlapping:
			return gauge
	return null

func confirm_cursor() -> void:
	if cursor_paused:
		return
	
	var confirmed_gauge: Gauge = check_gauged()
	if confirmed_gauge == null:
		stun_cursor()
	else:
		squish_cursor(3.0, stun_time)
		var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(
			self, "cursor_color", Color.WHITE, stun_time
		).from(Color.GREEN)
