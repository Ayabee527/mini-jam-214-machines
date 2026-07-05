extends Node2D

@export var dial: Dial
@export var bg_color: ColorRect

var dial_state: DialState

func _ready() -> void:
	dial_state = dial.get_state()
	add_start_gauge()

func add_start_gauge() -> void:
	var sg = Gauge.new()
	sg.color = Color.WHITE
	sg.lifetime = 600
	sg.width = 0.1
	sg.start_angle = PI/2.0
	dial_state.add_gauge(sg)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_restart") and OS.is_debug_build():
		get_tree().reload_current_scene()


func _on_dial_gauge_confirmed(id: int) -> void:
	if id == GameManager.GaugeID.START_GAME:
		print("game started")


func _on_dial_cursor_missed() -> void:
	pass
	#var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(
		#bg_color, "color", Color("34283e"), 0.5
	#).from(Color(0.275, 0.0, 0.0, 1.0))
