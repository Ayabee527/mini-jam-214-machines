extends Node

const GRID_SIZE: int = 14
const GRID_BOUNDS: Rect2i = Rect2i(0, 0, GRID_SIZE, GRID_SIZE)

@export var grid_offset: int = 8
@export var tile_size: int = 16

var occupied: PackedVector2Array = PackedVector2Array()

func get_closest_in_group(position: Vector2, group: StringName) -> Node2D:
	var members: Array = get_tree().get_nodes_in_group(group)
	var eligible: Array[Node2D] = []
	for member in members:
		if member is Node2D:
			eligible.append(member)
	
	var closest_candidate: Node2D = eligible[0]
	var closest_dist: float = INF
	for candidate in eligible:
		var dist = position.distance_squared_to(candidate.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_candidate = candidate
	
	return closest_candidate

func get_global_from_tile_position(pos: Vector2i, centered: bool = true) -> Vector2:
	var new_pos: Vector2 = Vector2(pos * tile_size) + (Vector2.ONE * grid_offset)
	if centered:
		new_pos += Vector2.ONE * tile_size / 2
	new_pos += Vector2.ONE
	return new_pos

func get_tile_from_global_position(pos: Vector2, centered: bool = true) -> Vector2:
	var new_pos: Vector2 = pos - (Vector2.ONE * grid_offset)
	if centered:
		new_pos -= Vector2.ONE * tile_size * 0.5
	new_pos /= tile_size
	return new_pos

func occupy_tile(tile_pos: Vector2) -> void:
	if not occupied.has(tile_pos):
		occupied.append(tile_pos)

func unoccupy_tile(tile_pos: Vector2) -> void:
	if occupied.has(tile_pos):
		occupied.erase(tile_pos)

func get_random_occupied_tile() -> Vector2:
	if occupied.size() > 0:
		return occupied[randi() % occupied.size()]
	else:
		return Vector2.INF

func get_random_unoccupied_tile() -> Vector2:
	var total_slots = (GRID_SIZE + 1) ** 2
	var available_indices: PackedInt32Array = PackedInt32Array()
	
	var occupied_indices = {}
	for tile in occupied:
		var idx = int((tile.y * 15) + tile.x)
		occupied_indices[idx] = true
	
	for i in range(total_slots):
		if not occupied_indices.has(i):
			available_indices.append(i)
	
	if available_indices.is_empty():
		return Vector2(-1, -1)
	
	var choice = available_indices[randi() % available_indices.size()]
	var x = choice % 15
	var y = choice / 15
	return Vector2(x, y)
