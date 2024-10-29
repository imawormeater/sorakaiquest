extends CanvasLayer
@export var bankDollars := 0.0
@export var collectSoundSFX:Array[Resource] = []

@onready var moneyLabel := $Bank/moneyAmm
@onready var bankControl := $Bank
@onready var collectSound := $CollectSound
@onready var dollarImage := $SubViewportContainer/dollar
@onready var coinImage := $SubViewportContainer/coin

@onready var albumControl := $AlbumCounter
@onready var albumImage := $AlbumCounter/album
@onready var albumText := $AlbumCounter/album/c

var isBankHere := false
var goAwayTimer := -1.0
var goAwayTimerInit := 5.0

var goodbyePos := Vector2(640,-90)
var helloPos := Vector2(640,0)
var defaultTextMoneySize:Vector2

func _ready() -> void:
	get_parent().loganGetMoney.connect(recievedMoney)
	get_parent().albumCounterAnimation.connect(onAlbumCollected)
	defaultTextMoneySize = moneyLabel.scale
	albumControl.position = Vector2(0,150)
	
func goodBye() -> void:
	if not isBankHere: return
	isBankHere = false
	var poop := get_tree().create_tween()
	poop.tween_property(bankControl,"position",goodbyePos,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
func hello() -> void:
	if isBankHere: return
	isBankHere = true
	var poop := get_tree().create_tween()
	poop.tween_property(bankControl,"position",helloPos,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _process(delta: float) -> void:
	var _lerp_speed:float = 1-pow(0.000000000005,delta)
	doTimers(delta)
	if goAwayTimer < 0 and not get_parent().inHub:
		goodBye()
		return
	else:
		hello()
		
	var funstring:String = str(bankDollars).pad_decimals(2)
	moneyLabel.text = "[right]" + funstring + " "
	moneyLabel.scale = moneyLabel.scale.lerp(defaultTextMoneySize,_lerp_speed*0.3)
	

func createMoneyImage(which:String) -> Sprite2D:
	var sprite2d:Sprite2D = dollarImage
	if which == "coin":
		sprite2d = coinImage
		
	var new := sprite2d.duplicate()
	new.visible = true
	$SubViewportContainer.add_child(new)
	return new

func recievedMoney(dictMom:Dictionary) -> void:
	goAwayTimer = goAwayTimerInit
	var newBankMoney:float = GameManager.CurrentState.bankMoney
	var which:String = dictMom["which"]
	
	var image := createMoneyImage(which)
	image.position = get_viewport().get_camera_3d().unproject_position(dictMom["global_pos"])

	var tween1 := get_tree().create_tween()
	tween1.tween_property(image,"position",Vector2(547,36),0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	$CollectSound2.play()
	await get_tree().create_timer(0.41,false).timeout
	image.queue_free()
	var tween2 := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween2.tween_property(self,"bankDollars",newBankMoney,0.3)
	moneyLabel.scale += Vector2(0.2,0.2)
	collectSound.stream = collectSoundSFX.pick_random()
	collectSound.play()
	
func doTimers(delta:float) -> void:
	if goAwayTimer > 0:
		goAwayTimer -= delta

func onAlbumCollected() -> void:
	albumControl.position = Vector2(0,140)
	var tween1 := get_tree().create_tween()
	tween1.tween_property(albumControl,"position",Vector2(0,0),0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(1).timeout
	albumControl.scale = Vector2.ONE*1.3
	var tweeny := get_tree().create_tween()
	tweeny.tween_property(albumControl,"scale",Vector2.ONE,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	albumText.text = "[center]" + str(GameManager.CurrentState.numberOfAlbums)
	$AlbumCollected.play()
	await get_tree().create_timer(1).timeout
	var tween2 := get_tree().create_tween()
	tween2.tween_property(albumControl,"position",Vector2(0,140),0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

#UI
var prevhidden:bool
func gamepause(paused:bool) -> void:
	if paused:
		prevhidden = visible
		hide()
	else:
		visible = prevhidden
