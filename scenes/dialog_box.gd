extends CanvasLayer
class_name DialogBox

@export var currentspeaker:Node3D = null
@export var tailMag := 63.0
@export var tailWidth := 20.0

var visibleOnScreenforSpeaker:VisibleOnScreenNotifier3D
var active := false

@onready var dialogboundary := $DialogBoundary
@onready var tail := $DialogBoundary/Frame/Tail
@onready var dialogText := $DialogText
@onready var incTimer := $Increment
@onready var continueButton := $ContinueButton
var initPoint := Vector2(320,350)

var hidden := true

var Dialog:Array
var curIndex := 0
var msgIndex := 0
var stagnant := false

var ExampleDialog:Array

func _ready() -> void:
	set_speaker(currentspeaker)
	ExampleDialog = [
		[currentspeaker,"Welcome to [color=57C8DB]Sorakai Quest!!!"],
		['player',"Woah... This is the coolest thing ever created."],
		[currentspeaker,"I know."]
	]
	
func appear() -> void:
	show()

func disappear() -> void:
	hide()

func play_dialog(Speech:Array) -> void:
	if Speech == []:
		Speech = ExampleDialog
	
	curIndex = -1
	Dialog = Speech
	active = true
	appear()
	doCurIndex()

func stop_dialog() -> void:
	active = false
	disappear()

func doCurIndex() -> void:
	curIndex += 1
	if len(Dialog) == curIndex:
		stop_dialog()
		return
		
	continueButton.hide()
	var curTable:Array = Dialog[curIndex]
	var speaker = curTable[0]
	var msg = curTable[1]
	stagnant = true
	if str(speaker) == "player":
		speaker = GameManager.CurrentState.Sorakai
	set_speaker(speaker)
	dialogText.text = "[center]" + msg
	msgIndex = 0
	dialogText.visible_characters = msgIndex
	incTimer.start()
	
func _on_increment_timeout() -> void:
	msgIndex += 1
	dialogText.visible_characters = msgIndex
	if dialogText.visible_characters >= dialogText.get_total_character_count() + 1:
		dialogText.visible_characters = -1
		incTimer.stop()
		continueButton.show()
		stagnant = false
	

func set_polygon(_position:Vector2,delta:float) -> void:
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

func set_speaker(speaker:Node3D) -> void:
	if speaker == null:
		return
	currentspeaker = speaker
	for i in currentspeaker.get_children():
		if i is VisibleOnScreenNotifier3D:
			visibleOnScreenforSpeaker = i
			break
	

func _process(delta: float) -> void:
	if not active: return
	
	if Input.is_action_just_pressed("movement_jump"):
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

var prevhidden:bool
func gamepause(paused:bool) -> void:
	if paused:
		prevhidden = visible
		hide()
	else:
		visible = prevhidden


