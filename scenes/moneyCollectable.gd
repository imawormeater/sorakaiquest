extends Node3D
class_name moneyCollectable

@export var value := 1.0

func _ready() -> void:
	pass
	
func _on_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		GameManager.CurrentState.receiveMoney.emit(self)
