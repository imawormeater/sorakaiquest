extends Node

var canPause := true

var App:Node
var CurrentState:Node

const SAVE_DIR = "user://save/"
const SETTINGS_FILE_NAME = "settings.tres"#tres so people can edit their settings as they please :)

var settings = GameSettings.new()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_settings()

func _ready() -> void:
	verify_save_directory(SAVE_DIR)
	load_settings()
	
func verify_save_directory(path:String) -> void:
	DirAccess.make_dir_absolute(path)

func save_settings() -> void:
	ResourceSaver.save(settings,SAVE_DIR + SETTINGS_FILE_NAME)
	
func update_settings() -> void:
	for i in settings.audioVolume:
		var value = settings.audioVolume[i]
		AudioServer.set_bus_volume_db(i,value)
	Engine.max_fps = settings.maxfps
	if settings.vysnc:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
	var oldres = DisplayServer.window_get_size()
	DisplayServer.window_set_size(settings.resolution)
	var difference:Vector2i = Vector2i(oldres.x-settings.resolution.x,oldres.y-settings.resolution.y)/2
	DisplayServer.window_set_position(DisplayServer.window_get_position() + difference)
	
func load_settings() -> void:
	if ResourceLoader.exists(SAVE_DIR + SETTINGS_FILE_NAME,"GameSettings") == false:
		save_settings()
	else:
		settings = ResourceLoader.load(SAVE_DIR + SETTINGS_FILE_NAME).duplicate(true)
		
	update_settings()

func settings_set_audiovolume() -> void:
	for i in settings.audioVolume:
		settings.audioVolume[i] = AudioServer.get_bus_volume_db(i)
