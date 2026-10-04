extends CharacterBody2D

@export var gravity := 960.0
@export var friction := 180.0
@export var acceleration := 240.0
@export var maximum_speed := 170.0
var pending_push := 0.0
@export var growth_factor: float = 2.0

var enlarged := false
var original_size: Vector2
var original_collision_position: Vector2
var original_sprite_position: Vector2
var original_sprite_scale: Vector2

func _ready() -> void:
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()

	var rectangle := $CollisionShape2D.shape as RectangleShape2D
	original_size = rectangle.size

	original_collision_position = $CollisionShape2D.position
	original_sprite_position = $Sprite2D.position
	original_sprite_scale = $Sprite2D.scale
	# 让每个箱子拥有独立的碰撞形状，之后放大缩小箱子不会影响其他实例
func push(amount: float) -> void:
	pending_push = amount

func _physics_process(delta: float) -> void:
	var boost := 0.0

	for tile in get_tree().get_nodes_in_group("accelerators"):
		if tile.active and tile.supports(self):
			boost = tile.direction
			break

	if boost != 0.0:
		velocity.x = move_toward(
			velocity.x,
			boost * maximum_speed,
			acceleration * delta
		)
	elif is_on_floor():
		velocity.x = move_toward(
			velocity.x,
			0.0,
			friction * delta
		)

	if pending_push != 0.0:
		velocity.x = pending_push
		pending_push = 0.0

	velocity.y += gravity * delta
	move_and_slide()

	crush_bricks_underneath()

func on_yellow_hit() -> void:
	if enlarged:
		return

	var new_size := original_size * growth_factor

	# 高度增加多少，中心就上移其一半，保持底边固定。
	var shift := Vector2(
		0.0,
		-(new_size.y - original_size.y) * 0.5
	)
	var new_center := original_collision_position + shift

	var clearance := RectangleShape2D.new()
	clearance.size = new_size - Vector2(0.2, 0.2)

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = clearance
	query.transform = $CollisionShape2D.global_transform
	query.transform.origin = to_global(new_center)
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]
	query.margin = 0.01

	var hits := get_world_2d().direct_space_state.intersect_shape(query)

	for hit in hits:
		var obstacle = hit.collider

		if obstacle is Node and obstacle.is_in_group("fragile_bricks"):
			continue

		return

	var new_shape := RectangleShape2D.new()
	new_shape.size = new_size

	$CollisionShape2D.shape = new_shape
	$CollisionShape2D.position = new_center

	$Sprite2D.scale = original_sprite_scale * growth_factor
	$Sprite2D.position = original_sprite_position + shift

	enlarged = true
	
func bottom() -> float:
	var rectangle := $CollisionShape2D.shape as RectangleShape2D

	return (
		$CollisionShape2D.global_position.y
		+ rectangle.size.y * absf($CollisionShape2D.global_scale.y) * 0.5
	)

func half_width() -> float:
	var rectangle := $CollisionShape2D.shape as RectangleShape2D

	return (
		rectangle.size.x
		* absf($CollisionShape2D.global_scale.x)
		* 0.5
	)
			
func crush_bricks_underneath() -> void:
	if not enlarged:
		return

	var strip := RectangleShape2D.new()
	strip.size = Vector2(half_width() * 2.0 - 0.2, 2.0)

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = strip
	query.transform = Transform2D(
		0.0,
		Vector2(global_position.x, bottom() + 1.0)
	)
	query.collision_mask = 1
	query.exclude = [get_rid()]
	query.margin = 0.0

	var hits := get_world_2d().direct_space_state.intersect_shape(
		query,
		64
	)

	for hit in hits:
		var brick = hit.collider

		if brick is Node and brick.is_in_group("fragile_bricks"):
			brick.crush()
