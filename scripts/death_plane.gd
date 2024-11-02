extends Node3D
@export var timeTilDead := 2.0
var active:Node3D = null

func _ready() -> void:
	hide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"): return
	if body.dying: return
	
	active = body
	body.die()
	await get_tree().create_timer(timeTilDead,false).timeout
	active = null
	if GameManager.CurrentState.Sorakai.dying:
		GameManager.CurrentState.reload_player()

func _process(_delta: float) -> void:
	if active == null: return
	get_viewport().get_camera_3d().look_at(active.global_position)
