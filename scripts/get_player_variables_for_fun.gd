extends Label
@export var logan:CharacterBody3D

func _ready() -> void:
	if not OS.is_debug_build():
		visible = false

func _process(_delta: float) -> void:
	var format_string = "velocity:%s\nspeed:%s\nstate:%s\naccel_mult:%s\nposition:%s\nhp:%s"
	var actual_string = format_string % [logan.velocity, logan.SPEED,logan.state,logan.DEACEL_mult,logan.global_position,1]

	text = actual_string
