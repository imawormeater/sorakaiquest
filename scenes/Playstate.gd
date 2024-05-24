extends Node3D

signal new_level_loaded

@export var Sorakai:CharacterBody3D
@export var MusicStream:AudioStreamPlayer
@export var smoother:Smoother

@export var first_level:PackedScene
@export var currentLevel:Level

var loganScene = preload("res://scenes/player_sorakai.tscn")

# Called when the node enters the scene tree for the first time.
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
	print("Setting Up Level: ",currentLevel.name)
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
		print("Logan Spawn doesn't exist! Setting player to (0,0,0)")
		Sorakai.global_position = Vector3.ZERO
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
	var newlevel:Level = loaded_level.instantiate()
	add_child(newlevel)
	currentLevel = newlevel
	new_level_loaded.emit()

func reload_player() -> void:
	Sorakai.queue_free()
	var newplayer = loganScene.instantiate()
	Sorakai = newplayer
	add_child(newplayer)
	new_level_loaded.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_page_up"):
		reload_player()
