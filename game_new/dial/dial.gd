class_name Dial
extends Node2D

const MAX_DIAL: float = 100.0

@export var clockwise: bool = true
@export var cursor_paused: bool = false
@export var period: float = 4.0
@export var stun_time: float = 0.2

@export_group("Graphics")
@export var radius: float = 60.0
@export var breadth: float = 4.0
@export_subgroup("Cursor", "cursor")
@export_range(0.0, 0.5, 0.005) var cursor_half_width: float = 0.01
@export var cursor_sheath: float = 4.0
@export var cursor_outline: float = 4.0

var dial_amount: float = 0.0
var active_components

var cursor_length: float = 0.0
var cursor_radius: float = 0.01
var cursor_color: Color = Color.WHITE

func _ready() -> void:
	cursor_length = breadth + cursor_sheath
	cursor_radius = cursor_half_width * TAU

func _process(delta: float) -> void:
	if not cursor_paused:
		if clockwise:
			dial_amount += (MAX_DIAL / period) * delta
		else:
			dial_amount -= (MAX_DIAL / period) * delta
		dial_amount = fposmod(dial_amount, MAX_DIAL)
	
	queue_redraw()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("confirm"):
		confirm_cursor()

func _draw() -> void:
	draw_circle(
		Vector2.ZERO, radius,
		Color("191919ff"), false, breadth
	)
	var ang: float = (dial_amount / MAX_DIAL) * TAU
	var cursor_outline_radius: float = cursor_radius + (cursor_outline / radius)
	draw_arc(
		Vector2.ZERO, radius,
		ang - (cursor_outline_radius / 2.0), ang + (cursor_outline_radius / 2.0),
		4, Color.BLACK, cursor_length + cursor_outline
	)
	draw_arc(
		Vector2.ZERO, radius,
		ang - (cursor_radius / 2.0), ang + (cursor_radius / 2.0),
		4, cursor_color, cursor_length
	)

func stun_cursor() -> void:
	var stun_factor: float = 4.0
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	tween.tween_property(
		self, "cursor_radius", cursor_half_width * TAU, stun_time
	).from(cursor_radius / stun_factor)
	tween.tween_property(
		self, "cursor_length", breadth + cursor_sheath, stun_time
	).from((breadth * stun_factor) + cursor_sheath)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(
		self, "cursor_color", Color.WHITE, stun_time
	).from(Color.RED)
	cursor_paused = true
	await tween.finished
	cursor_paused = false

func confirm_cursor() -> void:
	if cursor_paused:
		return
	
	stun_cursor()
