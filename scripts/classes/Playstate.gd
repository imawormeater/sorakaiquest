extends Node3D

signal new_level_loaded
signal game_paused
signal receiveMoney
signal loganGetMoney

@export var Sorakai:CharacterBody3D
@export var MusicStream:AudioStreamPlayer
@export var smoother:Smoother
@export var Dialog:DialogBox

@export var first_level:PackedScene
@export var currentLevel:Level

@export var hubLevel:String = "res://scenes/levels/test_level.tscn"
var inHub := false
var loganScene:PackedScene = preload("res://scenes/player_sorakai.tscn")

var bankMoney := 0.0

func _ready() -> void:
	new_level_loaded.connect(set_level_stuff)
	for i in get_children():
		if i is Level:
			print("Level is already in MainGameState")
			currentLevel = i
			set_level_stuff()
			return
			
	init_level(first_level)

func set_level_stuff()->void:
	if currentLevel.Song != null:#CHANGE ALL OF THESE TO FADE ONE DAY
		MusicStream.stop()
		MusicStream.stream = currentLevel.Song
		MusicStream.play()
	if currentLevel.Mute_Music:
		MusicStream.stop()
		
	Sorakai.velocity = Vector3.ZERO
	Sorakai.SPEED = 5
	if currentLevel.Logan_Spawn != null:
		#Sorakai.global_rotation = currentLevel.Logan_Spawn.global_rotation fix this someday
		Sorakai.global_position = currentLevel.Logan_Spawn.global_position
	else:
		push_warning("Logan Spawn doesn't exist!")
	smoother.reset_node(Sorakai)

func load_level(loaded_level_path:String) -> void:
	var packedscene = load(loaded_level_path)
	if packedscene == null:
		push_warning("Incorrect Level Path, Loading Cancelled.")
		return
	init_level(packedscene)

func init_level(loaded_level:PackedScene) -> void:
	if currentLevel != null:
		currentLevel.queue_free()
	inHub = false
	if loaded_level.resource_path == hubLevel:
		inHub = true
	var newlevel:Level = loaded_level.instantiate()
	add_child(newlevel)
	currentLevel = newlevel
	new_level_loaded.emit()
	Sorakai.refresh()

func reload_player() -> void:
	Sorakai.queue_free()
	var newplayer = loganScene.instantiate()
	Sorakai = newplayer
	add_child(newplayer)
	new_level_loaded.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Engine.max_fps < 60 and !Engine.max_fps == 0):
		smoother.add_exclude_node(Sorakai)
	elif smoother.excludes != []:
		smoother.remove_exclude_node(Sorakai)
	if Input.is_action_just_pressed("ui_page_up"):
		Dialog.play_dialog([])


func _on_receive_money(dollar:moneyCollectable) -> void:
	var dictInfo := {
		"value" : dollar.value,
		"global_pos" : dollar.global_position,
		"global_trans" : dollar.global_transform,
	}
	bankMoney += dictInfo["value"]
	dollar.queue_free()
	loganGetMoney.emit(dictInfo)
