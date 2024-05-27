extends CanvasLayer

@export var currentspeaker:Node3D = null
var visibleOnScreenforSpeaker:VisibleOnScreenNotifier3D

@onready var dialogboundary := $DialogBoundary
@onready var tail := $DialogBoundary/Frame/Tail
var tailMag := 63.0

func _ready() -> void:
	set_speaker(currentspeaker)

func set_polygon(_position:Vector2,delta:float):
	var _lerp_speed:float = 1-pow(0.000000000005,delta)
	
	var polygon1:Vector2 = tail.polygon[1]
	polygon1 = polygon1.lerp(_position - tail.global_position,_lerp_speed)
	
	#polygon1.x = clampf(polygon1.x,-220.0,220.0)
	#polygon1.y = clampf(polygon1.y,-156.0,-96.0)
	polygon1.y = clampf(polygon1.y,-999.0,-96.0)
	
	tail.polygon[0][0] = (polygon1.x/1.5) + 20
	tail.polygon[2][0] = (polygon1.x/1.5) - 20
	tail.polygon[1] = polygon1

func set_speaker(speaker:Node3D):
	if speaker == null:
		return
	currentspeaker = speaker
	for i in currentspeaker.get_children():
		if i is VisibleOnScreenNotifier3D:
			visibleOnScreenforSpeaker = i
			break
	

func _process(delta: float) -> void:
	var speakpos := Vector2(320,350)
	if currentspeaker != null:
		speakpos = get_viewport().get_camera_3d().unproject_position(currentspeaker.global_position)
		if visibleOnScreenforSpeaker != null:
			if not visibleOnScreenforSpeaker.is_on_screen():
				speakpos = Vector2(320,350)
	#print(speakpos)
	set_polygon(speakpos,delta)
