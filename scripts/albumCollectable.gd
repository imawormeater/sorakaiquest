extends Node3D

@onready var hitbox := $Hitbox

func _ready() -> void:
	print("FUCK MY LIFE")
	hitbox.body_entered.connect(onhit)

func onhit(body: Node3D) -> void:
	print("body ee")
	if not body.is_in_group("Player"): return
	$chimes.queue_free()
	$Sparkles.queue_free()
	$OmniLight3D.queue_free()
	GameManager.CurrentState.albumCollected.emit(self)
