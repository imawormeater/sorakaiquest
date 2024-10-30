extends Node3D

signal new_level_loaded
signal game_paused
signal receiveMoney#IT IS USED LEAVE ME ALONE
signal loganGetMoney
signal albumCollected
signal albumCounterAnimation

@export var Sorakai:Logan
@export var MusicStream:AudioStreamPlayer
@export var smoother:Smoother
@export var Dialog:DialogBox

@export var first_level:PackedScene

@export var currentLevel:Level
@export var storedLevel:Level

@export var hubLevel:String = "res://scenes/levels/test_level.tscn"
var inHub := false
var loganScene:PackedScene = preload("res://scenes/player_sorakai.tscn")
var checkPoint:Node3D = null

var bankMoney := 0.0
var allCollectedMoney := 0.0

var collectedAlbums:Array[int] = []
var numberOfAlbums:int = 0
var timeToCollect:float = 3.6

func _ready() -> void:
	new_level_loaded.connect(set_level_stuff)
	albumCollected.connect(on_album_collect)
	for i in get_children():
		if i is Level:
			print("Level is already in MainGameState")
			currentLevel = i
			set_level_stuff()
			return
	
	init_level(first_level)

func set_level_stuff()->void:
	if currentLevel.Song != null:#CHANGE ALL OF THESE TO FADE ONE DAY
		if MusicStream.stream != currentLevel.Song or not MusicStream.playing:
			MusicStream.stop()
			MusicStream.stream = currentLevel.Song
			MusicStream.play()
	if currentLevel.Mute_Music:
		MusicStream.stop()
		
	Sorakai.velocity = Vector3.ZERO
	Sorakai.SPEED = 5
	if currentLevel.Logan_Spawn != null:
		#Sorakai.global_rotation = currentLevel.Logan_Spawn.global_rotation fix this someday
		teleport_player(currentLevel.Logan_Spawn.global_position)
	else:
		push_warning("Logan Spawn doesn't exist!")
	if currentLevel.CurrentCheckpoint != null:
		teleport_player(currentLevel.CurrentCheckpoint.global_position)
	smoother.reset_node(Sorakai)

func load_level(loaded_level_path:String, isSubLevel:bool = false) -> void:
	var packedscene := load(loaded_level_path)
	if packedscene == null:
		push_warning("Incorrect Level Path, Loading Cancelled.")
		return
	if !isSubLevel:
		init_level(packedscene)
	else:
		init_sublevel(packedscene)

func init_level(loaded_level:PackedScene) -> void:
	if currentLevel != null:
		currentLevel.queue_free()
	if storedLevel != null:
		storedLevel.queue_free()
		storedLevel = null
	inHub = false
	if loaded_level.resource_path == hubLevel:
		inHub = true
	var newlevel:Level = loaded_level.instantiate()
	add_child(newlevel)
	currentLevel = newlevel
	new_level_loaded.emit()
	reload_player()
	#Sorakai.refresh()

func init_sublevel(loaded_level:PackedScene) -> void:
	if currentLevel != null:
		storedLevel = currentLevel
		remove_child(storedLevel)
	inHub = false
	var newlevel:Level = loaded_level.instantiate()
	add_child(newlevel)
	currentLevel = newlevel
	new_level_loaded.emit()
	reload_player()
	
func exit_sublevel() -> void:
	if currentLevel != null:
		currentLevel.queue_free()
	add_child(storedLevel)
	currentLevel = storedLevel
	storedLevel = null
	new_level_loaded.emit()
	reload_player()

func reload_player() -> void:
	Sorakai.queue_free()
	var newplayer:Logan = loganScene.instantiate()
	Sorakai = newplayer
	add_child(newplayer)
	new_level_loaded.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Engine.max_fps < 60 and !Engine.max_fps == 0):
		smoother.add_exclude_node(Sorakai)
	elif smoother.excludes != []:
		smoother.remove_exclude_node(Sorakai)

func play_dialog(speaker:Speaker) -> void:
	Dialog.play_dialog(speaker.getDialog())

func teleport_player(point:Vector3) -> void:
	Sorakai.global_position = point
	smoother.reset_node(Sorakai)

func _on_receive_money(dollar:moneyCollectable) -> void:
	var dictInfo := {
		"value" : dollar.value,
		"global_pos" : dollar.global_position,
		"global_trans" : dollar.global_transform,
		"which" : dollar.meshToUse.name
	}
	bankMoney += dictInfo["value"]
	allCollectedMoney += dictInfo["value"]
	dollar.queue_free()
	loganGetMoney.emit(dictInfo)

func on_album_collect(albumCollectable:Node3D) -> void:
	collectedAlbums += [albumCollectable.id]
	print(collectedAlbums)
	
	Sorakai.onAlbumCollect()
	get_tree().paused = true
	
	$AlbumCollectedSong.play()
	await get_tree().create_timer(timeToCollect).timeout
	
	get_tree().paused = false
	albumCounterAnimation.emit()
	Sorakai.onAlbumStop()
	numberOfAlbums = collectedAlbums.size()
	
	albumCollectable.deleteSelf()


func _on_game_paused(_paused:bool) -> void:
	pass # Replace with function body.
