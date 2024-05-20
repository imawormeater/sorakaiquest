extends Label
@export var logan:CharacterBody3D
	
func _process(delta: float) -> void:
	var format_string = "LOGAN NEAL STATS:\nvelocity:%s\nspeed:%s\nstate:%s\naccel_mult:%s"
	var actual_string = format_string % [logan.velocity, logan.SPEED,logan.state,logan.DEACEL_mult]

	text = actual_string
