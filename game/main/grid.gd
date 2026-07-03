extends Node2D

@export var offset: Vector2i = Vector2i(8,8)
@export var grid_size: Vector2i = Vector2i(16, 16)
@export var grid_nums: Vector2i = Vector2i(15, 15)
@export var grid_line_width: float = 2.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	for x in range(grid_nums.x):
		draw_line(
			Vector2i(offset.x + (x * grid_size.x), 0),
			Vector2i(offset.x + (x * grid_size.x), 256),
			Color("fff7cf").darkened(0.85),
			grid_line_width
		)
	
	for y in range(grid_nums.y):
		draw_line(
			Vector2i(0, offset.y + (y * grid_size.y)),
			Vector2i(256, offset.y + (y * grid_size.y)),
			Color("fff7cf").darkened(0.85),
			grid_line_width
		)
