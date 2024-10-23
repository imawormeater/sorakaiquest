extends Node3D

func _ready() -> void:
	hide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"): return
	if body.dying: return
	if GameManager.CurrentState.currentLevel.CurrentCheckpoint == self: return
	GameManager.CurrentState.currentLevel.CurrentCheckpoint = self
	print("hit checkpoint")
