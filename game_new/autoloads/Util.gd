extends Node

func slice_to_range(center: float, width: float) -> Vector2:
	var sweep: float = width * TAU
	var min_a: float = fposmod(center - (sweep / 2.0), TAU)
	return Vector2(
		min_a,
		min_a + sweep
	)

func get_occupied_ranges(slices: Dictionary[float, float]) -> Dictionary:
	var ranges: Array[Vector2] = []
	for slice: float in slices:
		var range: Vector2 = slice_to_range(slice, slices[slice])
		
		if range.y > TAU:
			ranges.append(Vector2(range.x, TAU))
			ranges.append(Vector2(0.0, range.y - TAU))
		else:
			ranges.append(range)
	
	ranges.sort_custom(
		func(a, b):
			return a.x < b.x
	)
	
	var merged: Dictionary[float, float] = {}
	for r: Vector2 in ranges:
		if merged.is_empty():
			merged[r.x] = r.y
		else:
			var last_key = merged.keys().back()
			var last = Vector2(last_key, merged[last_key])
			if r.x < last.y:
				last.y = max(last.y, r.y)
			else:
				merged[r.x] = r.y
	
	return merged

func get_random_unoccupied_angle(occupied_slices: Dictionary[float, float], required_width: float) -> float:
	var required_sweep: float = required_width * TAU
	var occupied_ranges = get_occupied_ranges(occupied_slices)
	
	var empty_ranges: Array[Vector2] = []
	var current_angle: float = 0.0
	
	for rm in occupied_ranges:
		if rm > current_angle:
			empty_ranges.append(Vector2(current_angle, rm))
		current_angle = max(current_angle, occupied_ranges[rm])
	
	if current_angle < TAU:
		empty_ranges.append(Vector2(current_angle, TAU))
	
	if empty_ranges.size() > 1 and empty_ranges.front().x == 0.0 and empty_ranges.back().y == TAU:
		var first = empty_ranges.pop_front()
		var last = empty_ranges.pop_back()
		empty_ranges.append(Vector2(last.x, TAU + first.y))
	
	var valid_gaps: Array[Vector2] = []
	for gap in empty_ranges:
		var gap_width = gap.y - gap.x
		if gap_width >= required_sweep:
			valid_gaps.append(gap)
	
	if valid_gaps.is_empty():
		return INF
	
	var chosen_gap = valid_gaps.pick_random()
	var max_start: float = chosen_gap.y - required_sweep
	var chosen_start: float = randf_range(chosen_gap.x, max_start)
	
	return fposmod(chosen_start + (required_sweep / 2.0), TAU)
	
