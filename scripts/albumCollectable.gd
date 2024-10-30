extends Node3D

@export var id:int = 0
@export var endingAlbum:bool = false
@onready var hitbox := $Hitbox

func _ready() -> void:
	#print("FUCK MY LIFE")
	await get_tree().create_timer(0.2).timeout
	if id in GameManager.CurrentState.collectedAlbums:
		print("Byee")
		self.queue_free()
	hitbox.body_entered.connect(onhit)

func onhit(body: Node3D) -> void:
	if not body.is_in_group("Player"): return
	$chimes.queue_free()
	$Sparkles.queue_free()
	$OmniLight3D.queue_free()
	GameManager.CurrentState.albumCollected.emit(self)
	hitbox.queue_free()

func deleteSelf() -> void:
	if not endingAlbum:
		self.queue_free()
		return
	
	self.visible = false
	GameManager.App.endParams = {
		CollectedMoney = GameManager.CurrentState.allCollectedMoney,
		AlbumsCollect = GameManager.CurrentState.numberOfAlbums,
		AmmountAlbums = GameManager.CurrentState.totalAlbums,#TODO 
		Deaths = GameManager.CurrentState.deathCount
	}
	GameManager.CurrentState.Sorakai.controlOn = false
	GameManager.CurrentState.Sorakai.cameraOn = false
	await get_tree().create_timer(2).timeout
	GameManager.App.play_transition("circle",1)
	await get_tree().create_timer(1).timeout
	GameManager.App.changeState(GameManager.App.EndState)
