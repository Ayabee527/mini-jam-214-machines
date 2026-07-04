class_name TaskSelect
extends PanelContainer

signal selected()


@export var task_name: String = "temperature"

@export var progress_bar: ProgressBar
@export var button: Button

func _ready() -> void:
	button.text = task_name


func _on_button_pressed() -> void:
	selected.emit()
