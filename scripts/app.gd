extends Node

@export var firstState:PackedScene
var currentState:Node = null

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
	pass


func _on_timer_timeout() -> void:#test thing
	changeState(firstState)
