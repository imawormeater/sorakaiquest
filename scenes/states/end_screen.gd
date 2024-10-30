extends CanvasLayer

var endParams:Dictionary = {
	CollectedMoney = 0,
	AlbumsCollect = 0,
	AmmountAlbums = 0,
}
enum rank {
	BAD,
	OK,
	SUPERB,
	PERFECT
}

@export var titleScreen:PackedScene

@onready var endSongs:Dictionary = {
	TryAgain = load("res://assets/music/ranks/tryagain.wav"),
	Ok = load("res://assets/music/ranks/ok.wav"),
	Superb = load("res://assets/music/ranks/superb.wav"),
	Perfect = null,
}

@onready var endSongs2:Dictionary = {
	TryAgain = null,
	Ok = null,
	Superb = null,
	Perfect = null,
}

@onready var judgementControl:Control = $Judgement
@onready var resultControl:Control = $Result

@onready var rankImage:TextureRect = $Judgement/Rank
@onready var resultImage:TextureRect = $Result/resultScreen

@onready var contents:RichTextLabel = $Judgement/Contents
@onready var resultText:RichTextLabel = $Result/resultText

@onready var progressLabel:TextureRect  = $progress

var canProgress:bool = false
var state:int = 1
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	endParams = GameManager.App.endParams
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print(endParams)
	judgementControl.hide()
	resultControl.hide()
	await get_tree().create_timer(2).timeout
	judgementControl.show()
	await get_tree().create_timer(1).timeout
	canProgress = true

func progress() -> void:
	progressLabel.hide()
	state += 1
	canProgress = false
	if state == 2:
		judgementControl.hide()
		resultControl.show()
		await get_tree().create_timer(1).timeout
		canProgress = true
		return
	if state == 3:
		GameManager.App.play_transition("circle",1)
		await get_tree().create_timer(1).timeout
		GameManager.App.changeState(titleScreen)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not canProgress: return
	
	if Input.is_action_just_pressed("interact"):
		progress()


func _on_progress_timer_timeout() -> void:
	if not canProgress: 
		progressLabel.hide() 
		return
	progressLabel.visible = !progressLabel.visible
