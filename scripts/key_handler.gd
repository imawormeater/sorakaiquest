extends Node3D
signal key_touched
signal lockedDoor_touched

func _on_key_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		key_touched.emit(self)


func _on_lockeddoor_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		lockedDoor_touched.emit(self)
