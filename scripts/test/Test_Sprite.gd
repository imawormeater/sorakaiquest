extends Sprite2D

func _process(delta: float) -> void:
	var mouse = get_global_mouse_position()
	position.x = lerp(position.x,mouse.x,delta)
	position.y = lerp(position.y,mouse.y,delta)
