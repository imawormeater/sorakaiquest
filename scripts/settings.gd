extends Resource
class_name GameSettings

@export var resolution := Vector2i(640,480)
@export var audioVolume := {
	0 : 0.0,
	1 : 0.0,
	2 : 0.0,
	3 : 0.0,
}
@export var vysnc := true
@export var maxfps := 0
