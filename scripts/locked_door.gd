extends Node3D


func unlockDoor() -> void:
	$explosion.play()
	$Door.queue_free()
	await $explosion.finished
	self.queue_free()

func _on_area_3d_area_entered(area: Area3D) -> void:
	print(area)
	if area.is_in_group("Keys"):
		var key:Equipable = area.get_parent().get_parent()
		GameManager.CurrentState.Sorakai.unequip()
		key.queue_free()
		unlockDoor()
