extends WorldEnvironment

func _process(delta: float) -> void:
	self.environment.sky_rotation.y += (delta/15) 
