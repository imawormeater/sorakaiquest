extends springResource
class_name balloonSpring
@export var time_to_come_back := 1.0

func on_bounce(spring:Node3D,area3d:Area3D,_body:Node3D) -> void:
	spring.hide()
	area3d.set_deferred("monitoring",false)
	await spring.get_tree().create_timer(time_to_come_back).timeout
	spring.show()
	area3d.set_deferred("monitoring",true)
