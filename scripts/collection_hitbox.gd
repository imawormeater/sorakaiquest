extends Area3D

var attractedBodies :Array[moneyCollectable]

func _physics_process(delta: float) -> void:
	for v in attractedBodies:
		if v != null:
			v.chaseSpeed += v.chaseAccel * delta
			v.global_position += (get_parent().global_position - v.global_position) * delta*v.chaseSpeed
		
func _on_area_entered(area: Area3D) -> void:
	var body := area.get_parent()
	if body.is_in_group("Collectable"):
		var money := body as moneyCollectable
		if !(money in attractedBodies):
			attractedBodies += [money]
	pass


func _on_collection_hitbox_area_entered(area: Area3D) -> void:
	
	var body := area.get_parent()
	if !body.is_in_group("Collectable"): return
	
	if body in attractedBodies:
		attractedBodies.erase(body)
		GameManager.CurrentState.receiveMoney.emit(body)
		return
