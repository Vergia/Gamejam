extends CharacterBody2D

var direction_x: float
var speed := 240
@export var jump_strength := 240
@export var gravity := 960
var can_jump := true 
signal shoot(pos: Vector2, dir: Vector2)     
enum FireMode { SINGLE, BURST }
var fire_mode: FireMode = FireMode.SINGLE
const SINGLE_COOLDOWN := 0.6    # 单击间隔（慢）
const BURST_COOLDOWN := 0.15    # 连击间隔（快）

func get_input():
	direction_x = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = -jump_strength
		can_jump = false
	# 根据模式选择检测方式
	var want_shoot := false
	match fire_mode:
		FireMode.SINGLE:
			want_shoot = Input.is_action_just_pressed("shoot")
		FireMode.BURST:
			want_shoot = Input.is_action_pressed("shoot")

	if want_shoot and $ReloadTimer.is_stopped():
		shoot.emit(position, get_local_mouse_position().normalized())
		var tween = get_tree().create_tween()
		tween.tween_property($marker, "scale", Vector2(0.1, 0.1), 0.2)
		tween.tween_property($marker, "scale", Vector2(0.5, 0.5), 0.4)
		$AudioStreamPlayer2D.play()
		$ReloadTimer.start()

func apply_gravity(delta):
	velocity.y += gravity * delta

func _physics_process(delta: float) -> void:
	if is_on_floor():
		can_jump = true
		
	# 模式切换
	if Input.is_action_just_pressed("switch_single"):
		fire_mode = FireMode.SINGLE
		$ReloadTimer.wait_time = SINGLE_COOLDOWN
		$marker.modulate = Color.WHITE    # 单击：白色准星
	if Input.is_action_just_pressed("switch_burst"):
		fire_mode = FireMode.BURST
		$ReloadTimer.wait_time = BURST_COOLDOWN
		$marker.modulate = Color.RED

	get_input()
	velocity.x = direction_x * speed # 设定x方向速度
	apply_gravity(delta)             # 设定y方向速度
	move_and_slide()				 # 人物运动
	animation()                      # 人物动画
	update_marker()                  # 射击准星位置
	
func animation():
	$legs.flip_h = direction_x < 0
	if is_on_floor():
		$AnimationPlayer.current_animation ="run" if direction_x else "idle"
	else:
		$AnimationPlayer.current_animation ="jump"
	var raw_dir = get_local_mouse_position().normalized()
	var idx = int(round(raw_dir.angle() / (PI / 4)))   # -4 ~ 4
	$torso.frame = (idx + 8) % 8

func update_marker():
	$marker.position = get_local_mouse_position()#.normalized() * 40
