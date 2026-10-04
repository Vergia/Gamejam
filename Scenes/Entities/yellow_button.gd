extends Area2D

@export_enum("yellow", "blue") var color := "yellow"
@export var off_texture: Texture2D
@export var on_texture: Texture2D

var pressed := false

func _physics_process(_delta: float) -> void:
	pressed = false

	for body in get_overlapping_bodies():
		if body.is_in_group("boxes"):
			var resting_on_button := (
				absf(body.bottom() - (global_position.y + 8.0)) < 3.0
			)

			if resting_on_button:
				pressed = true
				break

	$Sprite2D.texture = on_texture if pressed else off_texture
