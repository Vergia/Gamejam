extends StaticBody2D

@export var direction := 1.0

var active := false

func activate() -> void:
	active = true
	$active.show()
	$deactive.hide()
func is_adjacent(other: Node2D) -> bool:
	var offset := (
		other.global_position - global_position
	).abs()

	var horizontal := (
		absf(offset.x - 16.0) < 0.5
		and offset.y < 0.5
	)

	var vertical := (
		absf(offset.y - 16.0) < 0.5
		and offset.x < 0.5
	)

	return horizontal or vertical

func on_yellow_hit() -> void:
	var pending: Array[Node2D] = [self]
	var visited: Array[Node2D] = []

	var accelerators := get_tree().get_nodes_in_group("accelerators")

	while not pending.is_empty():
		var tile: Node2D = pending.pop_back()

		if tile in visited:
			continue

		visited.append(tile)
		tile.activate()

		for neighbor in accelerators:
			if neighbor not in visited and tile.is_adjacent(neighbor):
				pending.append(neighbor)

func supports(box: Node2D) -> bool:
	var touching_top: bool = (
		absf(box.bottom() - (global_position.y - 8.0)) < 2.0
	)

	var horizontal_overlap: bool = (
		absf(box.global_position.x - global_position.x)
		< box.half_width() + 7.5
	)

	return touching_top and horizontal_overlap
