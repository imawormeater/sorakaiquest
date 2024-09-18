extends CanvasLayer

enum states {Title, Select, Options, NewGame, Continue}
var state:states = states.Title
var active := true
@export var transTime:float
@export var continueState:PackedScene

@onready var splashControl := $Splash
@onready var selectControl := $Select
@onready var optionsControl := $Options

var controlDict:Dictionary

func _ready() -> void:
	controlDict = {
		states.Title : splashControl,
		states.Select : selectControl,
		states.Options : optionsControl,
	}
	get_tree().paused = false
	$TitleMusic.play()
	changeState(state)

func hideAllControls() -> void:
	for i:states in controlDict:
		var control:Control = controlDict[i]
		if control:
			control.hide()

func changeState(newstate:states) -> void:
	if not active: return
	var _oldstate := state
	state = newstate

	hideAllControls()
	if newstate == states.Title:
		splashControl.show()
	if newstate == states.Select:
		selectControl.show()
	if newstate == states.Options:
		optionsControl.show()
	if newstate == states.NewGame:
		active = false
	if newstate == states.Continue:
		active = false

func goToState(_state:PackedScene) -> void:
	active = false
	GameManager.App.play_transition("circle",transTime)
	await get_tree().create_timer(transTime).timeout
	GameManager.App.changeState(_state)
	
func _process(_delta: float) -> void:
	if state == states.Select:
		pass

func _input(event: InputEvent) -> void:
	if state == states.Title:
		if (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
			changeState(states.Select)

#SIGNALS
func _on_options_pressed() -> void:
	changeState(states.Options)
	
func _on_exit_pressed() -> void:
	optionsControl.get_node("settingsUI")
	changeState(states.Select)

func _on_start_pressed() -> void:
	goToState(continueState)

func _on_continue_pressed() -> void:
	goToState(continueState)
