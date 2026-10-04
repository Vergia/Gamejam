extends StaticBody2D

var broken := false

func crush() -> void:
	if broken:
		return

	broken = true
	$CollisionShape2D.set_deferred("disabled", true)
	hide()
	queue_free()
