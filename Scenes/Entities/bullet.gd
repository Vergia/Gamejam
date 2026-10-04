extends Node2D

@export var speed := 420.0

var direction := Vector2.RIGHT
var shooter: CollisionObject2D
var lifetime := 2.0

func _ready() -> void:
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	var next_position := global_position + direction * speed * delta

	# 第1层地形、第3层箱子、第5层加速器。
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		next_position,
		13
	)

	if is_instance_valid(shooter):
		query.exclude = [shooter.get_rid()]

	var hit := get_world_2d().direct_space_state.intersect_ray(query)

	if not hit.is_empty():
		var target = hit.collider

		if target is Node and target.has_method("on_yellow_hit"):
			target.on_yellow_hit()

		queue_free()
		return

	global_position = next_position
	lifetime -= delta

	if lifetime <= 0.0:
		queue_free()
