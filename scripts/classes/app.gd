extends Node

@export var firstState:PackedScene
var currentState:Node = null
var inTransition := false

@export var PlayState:PackedScene
@export var MainMenu:PackedScene
@export var EndState:PackedScene

@onready var animPlayer := $Main/Transitions/AnimationPlayer

var endParams:Dictionary = {
	CollectedMoney = 0,
	AlbumsCollect = 0,
	AmmountAlbums = 0,
}

func changeState(state:PackedScene) -> void:
	if state == null:
		push_warning("State is Null!")
		return
	if currentState != null:
		currentState.queue_free()
	
	
	var newstate := state.instantiate()
	print("Changed game state: ",newstate.name)
	add_child(newstate)
	
	currentState = newstate
	GameManager.CurrentState = currentState

func _ready() -> void:
	changeState(firstState)
	GameManager.App = self

func play_transition(which:String,speed:float) -> void:
	if inTransition:
		push_warning("Attempted Transition Failed, already in Transition")
		return
	if speed == 0: return
	inTransition = true
	GameManager.canPause = false
	animPlayer.speed_scale = 1/speed
	print(which,speed)

	if which.to_lower() == 'circle':
		animPlayer.play("circletransfull")
	await get_tree().create_timer(animPlayer.current_animation_length).timeout
	GameManager.canPause = true
	inTransition = false
