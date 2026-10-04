extends StaticBody2D

@export_enum("yellow", "blue") var color := "yellow"

var opened := false

func _physics_process(_delta: float) -> void:
	var should_open := false

	for button in get_tree().get_nodes_in_group("buttons"):
		if button.color == color and button.pressed:
			should_open = true
			break

	if opened != should_open:
		opened = should_open

		$Sprite2D.visible = not opened
		$CollisionShape2D.set_deferred("disabled", opened)
