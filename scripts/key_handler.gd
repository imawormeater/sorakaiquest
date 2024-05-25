extends Node3D
signal key_touched

func _on_key_entered(body: Node3D) -> void:
	if body == GameManager.CurrentState.Sorakai:
		key_touched.emit(self)
