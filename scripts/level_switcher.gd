extends Node3D

@export var levelpath:String
@export var transition := "circle"
@export var transitiontime := 1.0
@export var subLevel:bool = false
@export var goBackFromSubLevel:bool = false

var debounce := false
@onready var debouncetimer := $debounceTimer

func _ready() -> void:
	set_process(false)
	if not OS.is_debug_build():
		$tpArea/debug.visible = false

func _on_tp_area_body_entered(body: Node3D) -> void:
	if debounce: return
	if not body.is_in_group("Player"):
		return
		
	debounce = true
	if transitiontime == 0.0:
		if goBackFromSubLevel:
			GameManager.CurrentState.exit_sublevel()
		else:
			GameManager.CurrentState.load_level(levelpath,subLevel)
		debounce = false
		return
	GameManager.App.play_transition(transition,transitiontime)
	debouncetimer.wait_time = transitiontime
	debouncetimer.start()
	await debouncetimer.timeout
	if goBackFromSubLevel:
		GameManager.CurrentState.exit_sublevel()
	else:
		GameManager.CurrentState.load_level(levelpath,subLevel)
