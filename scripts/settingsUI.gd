extends Control

var audiosliders:Dictionary

@onready var audioSliders := $AudioSliders

@onready var fpsSlider := $WindowList/FPS
@onready var vsync := $WindowList/Vsync
@onready var windowdrop := $WindowList/Window
@onready var resolution := $WindowList/Resolution

var windowModes:Dictionary = {
	"windowed" : DisplayServer.WINDOW_MODE_WINDOWED,
	#["borderless window"] : DisplayServer.WINDOW_MODE_WINDOWED,
	"fullscreen" : DisplayServer.WINDOW_MODE_FULLSCREEN
}

var platform := 0 #1 is ios and mobile

var resolutions:Dictionary = {
	"640x480" : Vector2i(640,480),
	"800x600" : Vector2i(800,600),
	"960x720" : Vector2i(960,720),
	"1024x768" : Vector2i(1024,768),
	"1280x960" : Vector2i(1280,960),
	"1400x1050" : Vector2i(1400,1050),
	"1440x1080" : Vector2i(1440,1080),
	"1600x1200" : Vector2i(1600,1200),
	"1856x1392" : Vector2i(1856,1392),
	"1920x1440" : Vector2i(1920,1440),
}

func _ready() -> void:
	init_sliders()
	if OS.get_name() == "Web" or OS.get_name() == "iOS":
		platform = 1
	if platform == 1:
		windowdrop.queue_free()
		resolution.queue_free()

func checktosave() -> void:
	if platform == 1:
		GameManager.save_settings()

func init_sliders() -> void:
	for i:Control in audioSliders.get_children():
		if i is HSlider:
			var index:int = AudioServer.get_bus_index(i.name)
			if index != null:
				audiosliders[index] = i
	
	for i:int in audiosliders:
		var slider:HSlider = audiosliders[i]
		slider.value = AudioServer.get_bus_volume_db(i)
		slider.connect("value_changed",update_audio_slider.bind(i))
	
	fpsSlider.value = GameManager.settings.maxfps
	update_fps(GameManager.settings.maxfps)
	fpsSlider.value_changed.connect(update_fps)
	
	vsync.button_pressed = GameManager.settings.vsync
	
	windowdrop.clear()
	resolution.clear()
	
	for i:String in windowModes:
		windowdrop.add_item(i,windowdrop.item_count)
		if windowModes[i] == GameManager.settings.windowmode:
			windowdrop.selected = windowdrop.item_count -1 
		
	for i:String in resolutions:
		resolution.add_item(i,resolution.item_count)
		if resolutions[i] == GameManager.settings.resolution:
			resolution.selected = resolution.item_count -1 
	
func update_audio_slider(value:int,index:int) -> void:
	if value == -35:
		value = -80
	AudioServer.set_bus_volume_db(index,value)
	GameManager.settings_set_audiovolume()
	checktosave()

func update_fps(value:int) -> void:
	var stringValue := str(value)
	if value > 300 or value == 0:
		stringValue = "unlimited"
		value = 0
		fpsSlider.value = 310
	fpsSlider.get_child(0).text = "fps cap (" + stringValue + ")"
	GameManager.settings.maxfps = value
	checktosave()
	
func _on_vsync_pressed() -> void:
	GameManager.settings.vsync = vsync.button_pressed
	checktosave()

func _on_window_item_selected(index: int) -> void:
	var shitberries:DisplayServer.WindowMode = windowModes[windowdrop.get_item_text(index)]

	if shitberries == null:
		shitberries = DisplayServer.WINDOW_MODE_WINDOWED
	GameManager.settings.windowmode = shitberries
	GameManager.settings_update_window_mode()


func _on_resolution_item_selected(index: int) -> void:
	var shitberries:Vector2i = resolutions[resolution.get_item_text(index)]

	if shitberries == null:
		shitberries = resolutions["640x480"]
	GameManager.settings.resolution = shitberries
	GameManager.settings_update_resolution()
	GameManager.settings_update_window_mode()
