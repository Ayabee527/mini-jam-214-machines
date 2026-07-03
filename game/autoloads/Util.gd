extends Node

@export var tile_size: int = 16

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

func get_global_from_tile_position(pos: Vector2i) -> Vector2:
	return Vector2(pos * tile_size) - (Vector2.ONE * tile_size * 0.5)
