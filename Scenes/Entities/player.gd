extends CharacterBody2D

@export var speed := 100.0
@export var jump_strength := 260.0
@export var gravity := 960.0
var has_gun := false
var shot_cooldown := 0.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_strength
	velocity.y += gravity * delta
	move_and_slide()
	$AnimationPlayer.play("run" if direction else "idle")
	if direction:
		$playerSprite.flip_h = direction < 0.0
	update_gun(delta)
	#for index in get_slide_collision_count():
		#var contact := get_slide_collision(index)
		#var body = contact.get_collider()
#
		#if body is Node and body.has_method("push"):
			#if absf(contact.get_normal().x) > 0.5:
				#body.push(direction * speed)

func pickup_gun() -> void:
	has_gun = true
	$gun.visible = true	

const BULLET_SCENE = preload(
	"res://Scenes/Entities/bullet.tscn"
)

func update_gun(delta: float) -> void:
	shot_cooldown = maxf(0.0, shot_cooldown - delta)

	if not has_gun:
		return

	var aim := (
		get_global_mouse_position() - global_position
	).normalized()

	if aim.is_zero_approx():
		aim = Vector2.RIGHT

	$gun.position = aim * 9.0
	$gun.rotation = aim.angle()
	$gun.flip_v = aim.x < 0.0

	if Input.is_action_pressed("shoot") and shot_cooldown <= 0.0:
		var bullet = BULLET_SCENE.instantiate()
		bullet.direction = aim
		bullet.shooter = self

		get_parent().add_child(bullet)
		bullet.global_position = global_position

		shot_cooldown = 0.22	
