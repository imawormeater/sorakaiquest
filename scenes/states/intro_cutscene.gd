extends Node2D

@export var gameState:PackedScene 
@onready var video:VideoStreamPlayer = $VideoStreamPlayer
@onready var stream = preload("res://assets/videos/sorakai quest intro.ogv")
var bye:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	video.play()
	video.finished.connect(onVideoFinish)
	
func onVideoFinish():
	if bye: return
	bye = true
	video.stop()
	GameManager.App.play_transition("circle",1)
	await get_tree().create_timer(1).timeout
	GameManager.App.changeState(gameState)
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("ui_pause"):
		onVideoFinish()
