extends Resource
class_name GameSettings

@export var resolution := Vector2i(1024,768)
@export var audioVolume := {
	0 : 0.0,
	1 : 0.0,
	2 : 0.0,
	3 : 0.0,
}
@export var vsync := true
@export var maxfps := 0
@export var windowmode := DisplayServer.WINDOW_MODE_WINDOWED
