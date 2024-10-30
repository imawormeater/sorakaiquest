extends CanvasLayer

var endParams:Dictionary = {
	CollectedMoney = 0,
	AlbumsCollect = 0,
	AmmountAlbums = 0,
	Deaths = 0
}
enum rank {
	BAD,
	OK,
	SUPERB,
	PERFECT
}

@export var titleScreen:PackedScene

@onready var judgementControl:Control = $Judgement
@onready var resultControl:Control = $Result

@onready var rankImage:TextureRect = $Judgement/Rank
@onready var resultImage:TextureRect = $Result/resultScreen

@onready var contents:RichTextLabel = $Judgement/Contents
@onready var resultText:RichTextLabel = $Result/resultText

@onready var progressLabel:TextureRect  = $progress
@onready var transPanel:Panel  = $trans
#soundFX
@onready var progressSound:AudioStreamPlayer = $Progress
@onready var song:AudioStreamPlayer = $Song
@onready var rankStinger:AudioStreamPlayer = $RankStinger
@onready var resultMusic:AudioStreamPlayer = $ResultMusic
@onready var contentsAAA:AudioStreamPlayer = $Contents

var canProgress:bool = false
var state:int = 1
var Rank:rank = rank.BAD
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	endParams = GameManager.App.endParams
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print(endParams)
	var percentage:float = float(endParams["AlbumsCollect"])/float(endParams["AmmountAlbums"])
	print(percentage)
		
	Rank = rank.BAD
	if(percentage >= 0.7):
		Rank = rank.OK
	if(percentage >= 0.9):
		Rank = rank.SUPERB
	if(percentage == 1):
		Rank = rank.PERFECT
	
	var format_string:String = "You collected $%s.\nYou collected %s/%s albums.\nAnd you died %s times."
	var actual_string:String = format_string % [str(endParams["CollectedMoney"]).pad_decimals(2),endParams["AlbumsCollect"],endParams["AmmountAlbums"],endParams["Deaths"]]	
	contents.text = actual_string
	
	if(Rank == rank.BAD):
		resultText.text = "[center]I think it's my heart that is empty."
		#song.stream = load("res://assets/music/ranks/tryagain.wav")
		#rankStinger.stream = load("res://assets/music/ranks/init/tryagainRank.mp3")
		#resultMusic.stream = load("res://assets/music/ranks/results/tryagainResult.mp3")
	elif(Rank == rank.OK):
		song.stream = load("res://assets/music/ranks/ok (remux).wav")
		rankStinger.stream = load("res://assets/music/ranks/init/okRank.mp3")
		resultMusic.stream = load("res://assets/music/ranks/results/okResult.mp3")
		resultText.text = "[center]Lets go get some more!"
	elif(Rank == rank.SUPERB or Rank == rank.PERFECT):
		song.stream = load("res://assets/music/ranks/superb (remux).wav")
		rankStinger.stream = load("res://assets/music/ranks/init/superbRank.mp3")
		resultMusic.stream = load("res://assets/music/ranks/results/superbResult.mp3")
		resultText.text = "[center]Lost and found!"
	elif(Rank == rank.PERFECT):
		resultText.text = "[center]My collection is complete!"
		pass
		
	judgementControl.hide()
	resultControl.hide()
	await get_tree().create_timer(2).timeout
	contentsAAA.play()
	$Judgement/AnimationPlayer.play("anim")
	judgementControl.show()
	await $Judgement/AnimationPlayer.animation_finished
	canProgress = true

func progress() -> void:
	progressLabel.hide()
	progressSound.play(0.05)
	state += 1
	canProgress = false
	if state == 2:
		get_tree().create_tween().tween_property(song,"volume_db",-80,0.2)
		get_tree().create_tween().tween_property(transPanel,"self_modulate",Color.WHITE,0.2)
		await get_tree().create_timer(0.2).timeout
		judgementControl.hide()
		resultControl.show()
		await get_tree().create_timer(1).timeout
		transPanel.hide()
		resultMusic.play()
		await get_tree().create_timer(3).timeout
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
