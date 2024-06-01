@tool
extends Node3D
class_name moneyCollectable

@export var value := 1.0
@export var meshToUse:Node3D

@onready var visual := $Visual

var chasePlayer:Node3D = null#CHASE HUNTER
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

func _physics_process(delta: float) -> void:
	visual.rotate_y(delta)
	visual.position.y = sin(GameManager.sinTick*2)/9
	if chasePlayer != null:
		chaseSpeed += chaseAccel * delta
		global_position += (chasePlayer.global_position - global_position)*delta*chaseSpeed

func _on_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		GameManager.CurrentState.receiveMoney.emit(self)


func _on_near_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		chasePlayer = body
