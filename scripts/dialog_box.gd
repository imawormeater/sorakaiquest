extends CanvasLayer
class_name DialogBox

@export var speaker:Node3D
@export var tailMag := 63.0
@export var tailWidth := 20.0
var tailWidthVector := Vector2(tailWidth,0)

var visibleOnScreenforSpeaker:VisibleOnScreenNotifier3D
var active := false
var currentspeaker:Node3D = null

@onready var dialogboundary := $DialogBoundary
@onready var tail := $DialogBoundary/Tail
@onready var frame := $DialogBoundary/Frame
@onready var dialogText := $DialogText
@onready var incTimer := $Increment
@onready var continueButton := $ContinueButton
var initPoint := Vector2(320,350)

var hidden := true
var ending := false

var Dialog:Array
var curIndex := 0
var msgIndex := 0
var stagnant := false

var ExampleDialog:Array

var defaultSize:Vector2
var defaultPosition:Vector2

func _ready() -> void:
	ExampleDialog = [
		[speaker,"Welcome to [color=57C8DB]Sorakai Quest!!!"],
		['player',"Woah... This is the coolest thing ever created."],
		[speaker,"I know."],
		[speaker,"burger burger burger burger burger burger burger burger burger burger burger burger burger burger burger burger burger"],
		[speaker,"[wave]ohio"]
	]
	defaultPosition = frame.position
	defaultSize = frame.size
	
#START ANIMATION
func appear() -> void:
	show()
	tail.hide()
	hidden = true
	set_speaker(null)
	dialogboundary.modulate = Color.WHITE
	dialogText.text = ""
	continueButton.hide()
	var tweent := get_tree().create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	frame.size = Vector2(112,0)
	frame.position = Vector2(264,376)
	tweent.tween_property(frame,"size",defaultSize,0.6)
	tweent.tween_property(frame,"position",defaultPosition,0.6)

#END ANIMATION
func disappear() -> void:
	set_speaker(null)
	ending = true
	dialogText.text = ""
	continueButton.hide()
	var tweent := get_tree().create_tween().set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tweent.tween_property(frame,"position",Vector2(264,376),0.4)
	tweent.tween_property(frame,"size",Vector2(112,0),0.4)
	await get_tree().create_timer(0.4,false).timeout
	ending = false
	hide()

#BEGINS DIALOG
func play_dialog(Speech:Array) -> void:
	if Speech == []:
		Speech = ExampleDialog
	
	curIndex = -1
	Dialog = Speech
	appear()
	await get_tree().create_timer(0.6,false).timeout
	active = true
	doCurIndex()

#STOPS THE DIALOG
func stop_dialog() -> void:
	active = false
	disappear()

#CHANGES BOX TO FIT THE TEXT
func set_dialog_box() -> void:
	var vector := Vector2(dialogText.get_content_width(),dialogText.get_content_height())
	vector += Vector2(125,76)
	vector.y /= sqrt(vector.y/117)
	
	var oldsize:Vector2 = frame.size
	var newpos:Vector2 = frame.position + (Vector2(oldsize.x-vector.x,oldsize.y-vector.y)/2)

	var tweent := get_tree().create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tweent.tween_property(frame,"size",vector,0.5)
	tweent.tween_property(frame,"position",newpos,0.5)
	pass

#INITIATES THE CURRENT INDEX IN THE DIALOG
func doCurIndex() -> void:
	curIndex += 1
	if len(Dialog) == curIndex:
		stop_dialog()
		return
		
	continueButton.hide()
	var curTable:Array = Dialog[curIndex]
	var _speaker:Node3D = curTable[0]
	var msg:String = curTable[1]
	stagnant = true
	if str(_speaker) == "player":
		_speaker = GameManager.CurrentState.Sorakai
	set_speaker(_speaker)
	dialogText.text = "[center]" + msg
	msgIndex = 0
	dialogText.visible_characters = msgIndex
	set_dialog_box()
	incTimer.start()
	
#DIALOG PROGRESS
func _on_increment_timeout() -> void:
	msgIndex += 1
	dialogText.visible_characters = msgIndex
	if dialogText.visible_characters >= dialogText.get_total_character_count() + 1:
		dialogText.visible_characters = -1
		incTimer.stop()
		continueButton.show()
		stagnant = false
	
#TAIL HANDLER
func set_polygon(_position:Vector2,delta:float) -> void:
	var _lerp_speed:float = 1-pow(0.000000000005,delta)
	
	tail.position.y = frame.position.y + 110
	if hidden:
		tail.polygon[1][1] = lerpf(tail.polygon[1][1],-96,_lerp_speed)
		return
	
	var endpoint:Vector2 = _position - tail.global_position
	var beginpoint := Vector2(endpoint.x/1.3,-93)
	
	var sizeFrame:float = (frame.size.x/2) - 65
	
	beginpoint.y = clampf(beginpoint.y,-999.0,-96.0)
	beginpoint.x = clampf(beginpoint.x,-sizeFrame,sizeFrame)
	endpoint.y = clampf(endpoint.y,-999.0,-96.0)
	
	var vector:Vector2 = Vector2(endpoint.x-beginpoint.x,endpoint.y-beginpoint.y)
	vector = vector.normalized() * tailMag
	endpoint = vector + beginpoint
	
	tail.polygon[1] = tail.polygon[1].lerp(endpoint,_lerp_speed)
	tail.polygon[0] = tail.polygon[0].lerp(beginpoint + tailWidthVector,_lerp_speed)
	tail.polygon[2] = tail.polygon[2].lerp(beginpoint - tailWidthVector,_lerp_speed)

#SETS SPEAKER
func set_speaker(_speaker:Node3D) -> void:
	visibleOnScreenforSpeaker = null
	currentspeaker = null
	if _speaker == null:
		return
	currentspeaker = _speaker
	for i in currentspeaker.get_children():
		if i is VisibleOnScreenNotifier3D:
			visibleOnScreenforSpeaker = i
			break
	
#INPUTS AND TAIL HANDLING
func _process(delta: float) -> void:
	if ending:
		hidden = true
		set_polygon(initPoint,delta)
		return
	
	if not active: return
	
	if Input.is_action_just_pressed("movement_jump") or Input.is_action_just_pressed("movement_action"):
		if stagnant:
			msgIndex = 5555
			_on_increment_timeout()
		else:
			doCurIndex()
	
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

#UI SHIT
var prevhidden:bool
func gamepause(paused:bool) -> void:
	if paused:
		prevhidden = visible
		hide()
	else:
		visible = prevhidden
