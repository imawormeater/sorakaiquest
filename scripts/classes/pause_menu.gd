extends CanvasLayer

var paused:bool = false
var oldmousemode:Input.MouseMode

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
	
func refresh(playSound:bool = true) -> void:

	paused = !paused
	get_tree().call_group("UI","gamepause",paused)
	GameManager.CurrentState.game_paused.emit(paused)
	
	if playSound:
		pauseSound.play(0.06)
	
	var inhub:bool = GameManager.CurrentState.inHub
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
	if Input.is_key_pressed(KEY_SHIFT):
		GameManager.CurrentState.currentLevel.CurrentCheckpoint = null
	GameManager.CurrentState.reload_player()


func _on_resume_pressed() -> void:
	refresh()

func _on_exit_pressed() -> void:
	hide()
	GameManager.App.play_transition('circle',1)
	await get_tree().create_timer(1).timeout
	if GameManager.CurrentState.inHub:
		GameManager.App.changeState(GameManager.App.MainMenu)
	else:
		GameManager.CurrentState.load_level(GameManager.CurrentState.hubLevel)
		refresh(false)
	
