extends Node3D
@export var pointToBringBack:Node3D
@export var timeToDie := 0.5
var active:Node3D = null

@onready var area := $Area3D

func _ready() -> void:
	if pointToBringBack == null:
		push_warning("Bring Back Plane doesn't have a set bring back point! Self Destructing!")
		queue_free()
		return
		
	hide()
	$MeshInstance3D.queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"): return
	await get_tree().create_timer(timeToDie,false).timeout
	GameManager.CurrentState.teleport_player(pointToBringBack.global_position)
