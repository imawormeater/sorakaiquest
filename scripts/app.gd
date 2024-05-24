extends Node

@export var firstState:PackedScene
var currentState:Node = null
var inTransition := false

#@onready var circleTrans := $CanvasLayer/Transitions/CircleTrans
@onready var animPlayer := $CanvasLayer/Transitions/AnimationPlayer

func changeState(state:PackedScene) -> void:
	if state == null:
		push_warning("No beginning state!")
		return
	if currentState != null:
		currentState.queue_free()
	
	
	var newstate = state.instantiate()
	print("Changed game state: ",newstate.name)
	add_child(newstate)
	
	currentState = newstate
	GameManager.CurrentState = currentState

func _ready() -> void:
	changeState(firstState)
	GameManager.App = self



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_home"):
		$CanvasLayer/VideoStreamPlayer.play()

func play_transition(which:String,speed:float) -> void:
	if inTransition:
		push_warning("Attempted Transition Failed, already in Transition")
		return
	if speed == 0: return
	inTransition = true
	animPlayer.speed_scale = 1/speed
	print(which,speed)

	if which.to_lower() == 'circle':
		animPlayer.play("circletransfull")
	await get_tree().create_timer(animPlayer.current_animation_length).timeout
	inTransition = false
