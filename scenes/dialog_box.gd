extends CanvasLayer

@export var currentspeaker:Node3D = null
@export var tailMag := 63.0
@export var tailWidth := 20.0

var visibleOnScreenforSpeaker:VisibleOnScreenNotifier3D

@onready var dialogboundary := $DialogBoundary
@onready var tail := $DialogBoundary/Frame/Tail
var initPoint := Vector2(320,350)

var hidden := true

func _ready() -> void:
	set_speaker(currentspeaker)

func set_polygon(_position:Vector2,delta:float):
	var _lerp_speed:float = 1-pow(0.000000000005,delta)
	
	if hidden:
		tail.polygon[1][1] = lerpf(tail.polygon[1][1],-96,_lerp_speed)
		return
	
	var endpoint:Vector2 = _position - tail.global_position
	var beginpoint := Vector2(endpoint.x/1.3,-93)
	beginpoint.y = clampf(beginpoint.y,-999.0,-96.0)
	beginpoint.x = clampf(beginpoint.x,-225.0,225.0)
	
	var vector:Vector2 = Vector2(endpoint.x-beginpoint.x,endpoint.y-beginpoint.y)
	vector = vector.normalized() * tailMag
	endpoint = vector + beginpoint
	tail.polygon[1] = tail.polygon[1].lerp(endpoint,_lerp_speed)
	
	tail.polygon[0] = beginpoint + Vector2(tailWidth,0)
	tail.polygon[2] = beginpoint - Vector2(tailWidth,0)
	#tail.polygon[1] = endpoint

func set_speaker(speaker:Node3D):
	if speaker == null:
		return
	currentspeaker = speaker
	for i in currentspeaker.get_children():
		if i is VisibleOnScreenNotifier3D:
			visibleOnScreenforSpeaker = i
			break
	

func _process(delta: float) -> void:
	tail.show()
	var speakpos := initPoint
	hidden = false
	if currentspeaker != null:
		speakpos = get_viewport().get_camera_3d().unproject_position(currentspeaker.global_position)
		if visibleOnScreenforSpeaker != null:
			if not visibleOnScreenforSpeaker.is_on_screen():
				speakpos = initPoint
				hidden = true
	else:
		hidden = true
	set_polygon(speakpos,delta)
