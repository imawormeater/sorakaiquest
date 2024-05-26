extends CanvasLayer

var paused:bool = false
var oldmousemode

@onready var BG := $BG
@onready var pauseSound := $PauseSound

var audiosliders:Dictionary

func _ready() -> void:
	init_sliders()
	hide()
	
func init_sliders() -> void:#CHANGE THIS TO NOT BE SHIT LATER
	for i in $AudioSliders.get_children():
		if i is HSlider:
			var index:int = AudioServer.get_bus_index(i.name)
			if index != null:
				audiosliders[index] = i
	
	for i in audiosliders:
		var slider:HSlider = audiosliders[i]
		slider.value = AudioServer.get_bus_volume_db(i)
		slider.connect("value_changed",update_slider.bind(i))
	
func update_slider(value,index) -> void:
	AudioServer.set_bus_volume_db(index,value)
	GameManager.settings_set_audiovolume()
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_pause"):
		refresh() 
	if paused:
		BG.material["shader_parameter/offset"] += (Vector2(-0.1,0.1) * delta)
		pass
	
func refresh() -> void:

	paused = !paused
	get_tree().call_group("UI","gamepause",paused)
	GameManager.CurrentState.game_paused.emit(paused)
	pauseSound.play(0.06)
	if paused:
		show()
		oldmousemode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
	else:
		hide()
		Input.mouse_mode = oldmousemode
		get_tree().paused = false
