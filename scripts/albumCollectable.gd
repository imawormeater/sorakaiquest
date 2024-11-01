extends Node3D

@export var id:int = 0
@export var endingAlbum:bool = false

@export var albumName:String = "brat album"

@export var albumNames:Array[String] = ["SCARING THE HOES", "Madvillainy", "To Pimp a Butterfly",
"Emergency & I", "Marvin's Marvelous Mechanical Museum", "The College Dropout",
"Hawaii Part II", "i used to cry about it", "The Bends", "Good & Evil",
"Die Lit", "Flex Musix", "Atrocity Exhibition", "Late Registration",
"TA13OO", "Cherry Bomb", "ekitai", "1000 gecs",
"Pinkerton", "GET NAKED BY CHE", "Baby Blue Brother OST","Spirit Phone"]

@onready var albumTextures:Array = [
	preload("res://assets/images/albums/SCARING THE HOES.png"),
	preload("res://assets/images/albums/Madvillainy.png"),
	preload("res://assets/images/albums/To Pimp a Butterfly.png"),
	preload("res://assets/images/albums/Emergency & I.png"),
	preload("res://assets/images/albums/Marvin's Marvelous Mechanical Museum.png"),
	preload("res://assets/images/albums/The College Dropout.png"),
	preload("res://assets/images/albums/Hawaii Part II.png"),
	preload("res://assets/images/albums/i used to cry about it.png"),
	preload("res://assets/images/albums/The Bends.png"),
	preload("res://assets/images/albums/Good & Evil.png"),
	preload("res://assets/images/albums/Die Lit.png"),
	preload("res://assets/images/albums/Flex Musix.png"),
	preload("res://assets/images/albums/Atrocity Exhibition.png"),
	preload("res://assets/images/albums/Late Registration.png"),
	preload("res://assets/images/albums/TA13OO.png"),
	preload("res://assets/images/albums/Cherry Bomb.png"),
	preload("res://assets/images/albums/ekitai.png"),
	preload("res://assets/images/albums/1000 gecs.png"),
	preload("res://assets/images/albums/Pinkerton.png"),
	preload("res://assets/images/albums/GET NAKED BY CHE.png"),
	preload("res://assets/images/albums/Baby Blue Brother OST.png"),
	preload("res://assets/images/albums/Spirit Phone.png")
]

@onready var hitbox := $Hitbox
@onready var album := $album
@onready var albumMaterial:ShaderMaterial = $album/Armature/Skeleton3D/Cube.get("surface_material_override/0")


func _ready() -> void:
	if id >= albumNames.size():#U BITCHES DUMB
		id = albumNames.size()-1
	if id < 0:
		id = 0
	albumName = albumNames[id]
	albumMaterial["shader_parameter/Texture"] = albumTextures[id]
	
	await get_tree().create_timer(0.2).timeout
	if id in GameManager.CurrentState.collectedAlbums:
		self.queue_free()
	hitbox.body_entered.connect(onhit)

func onhit(body: Node3D) -> void:
	if not body.is_in_group("Player"): return
	$chimes.queue_free()
	$IdleSparkle.queue_free()
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
