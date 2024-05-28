extends CanvasLayer

var paused:bool = false
var oldmousemode

@onready var pauseSound := $PauseSound
@onready var exitButton := $Exit

var audiosliders:Dictionary

func _ready() -> void:
	hide()
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_pause"):
		if GameManager.canPause:
			refresh() 
	if not paused: return
	
	if Input.is_action_just_pressed("quick_restart"):
		_on_restart_pressed()
	
func refresh() -> void:

	paused = !paused
	get_tree().call_group("UI","gamepause",paused)
	GameManager.CurrentState.game_paused.emit(paused)
	pauseSound.play(0.06)
	
	var inhub = GameManager.CurrentState.inHub
	if inhub:
		exitButton.text = "Main Menu"
	else:
		exitButton.text = "Exit to Hub"
		
	if paused:
		show()
		oldmousemode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
	else:
		GameManager.update_settings()
		hide()
		Input.mouse_mode = oldmousemode
		get_tree().paused = false


func _on_restart_pressed() -> void:
	refresh()
	GameManager.CurrentState.reload_player()


func _on_resume_pressed() -> void:
	refresh()

func _on_exit_pressed() -> void:
	if GameManager.CurrentState.inHub:
		pass
	else:
		GameManager.CurrentState.load_level(GameManager.CurrentState.hubLevel)
	refresh()
	pass
