extends Node3D
@export var timeTilDead := 2.0
var active:Node3D = null

func _on_death_area_body_entered(body: Node3D) -> void:
	if !body is Logan: return
	var logan:Logan = body
	
	var equippedItem:Equipable = logan.equippedItem
	if equippedItem == null: return
	logan.unequip()
	equippedItem.queue_free()
