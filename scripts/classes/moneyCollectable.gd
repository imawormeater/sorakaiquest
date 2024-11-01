@tool
extends Node3D
class_name moneyCollectable

@export var value := 1.0
@export var meshToUse:Node3D
@onready var visual := $Visual

var chaseSpeed := 0.0
var chaseAccel := 45.0

func _ready() -> void:
	for i in visual.get_children():
		i.hide()
	if value >= 1:
		meshToUse = $Visual/bill
	else:
		meshToUse = $Visual/coin
	meshToUse.visible = true
	visual.rotation = Vector3.ZERO
	rotation = Vector3.ZERO

func deleteSelf() -> void:
	visual.hide()
	$IdleSparkle.hide()
	$NearRange.monitorable = false
	$CollectSparkle.emitting = true
	$CollectSparkle/Ring.emitting = true
	await get_tree().create_timer(1).timeout
	self.queue_free()
