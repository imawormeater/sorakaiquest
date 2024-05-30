extends CanvasLayer
@export var bankDollars := 0.0
@export var collectSoundSFX:Array[Resource] = []

@onready var moneyLabel := $Bank/moneyAmm
@onready var bankControl := $Bank
@onready var collectSound := $CollectSound
@onready var sprite2dtest := $SubViewportContainer/Sprite2D

var isBankHere := false
var goAwayTimer := -1.0
var goAwayTimerInit := 5.0

var goodbyePos := Vector2(640,-90)
var helloPos := Vector2(640,0)
var defaultTextMoneySize:Vector2

func _ready() -> void:
	get_parent().loganGetMoney.connect(recievedMoney)
	defaultTextMoneySize = moneyLabel.scale
	
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
	if goAwayTimer < 0 and not GameManager.CurrentState.inHub:
		goodBye()
		return
	else:
		hello()
		
	var funstring = str(bankDollars).pad_decimals(2)
	moneyLabel.text = "[right]" + funstring + " "
	moneyLabel.scale = moneyLabel.scale.lerp(defaultTextMoneySize,_lerp_speed*0.3)

func createMoneyImage() -> Sprite2D:
	var new := sprite2dtest.duplicate()
	new.visible = true
	$SubViewportContainer.add_child(new)
	return new

func recievedMoney(dictMom:Dictionary) -> void:
	goAwayTimer = goAwayTimerInit
	var newBankMoney = GameManager.CurrentState.bankMoney
	
	var image := createMoneyImage()
	image.position = get_viewport().get_camera_3d().unproject_position(dictMom["global_pos"])

	var tween1 = get_tree().create_tween()
	tween1.tween_property(image,"position",Vector2(547,36),0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	$CollectSound2.play()
	await get_tree().create_timer(0.41).timeout
	image.queue_free()
	var tween2 = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween2.tween_property(self,"bankDollars",newBankMoney,0.3)
	moneyLabel.scale += Vector2(0.2,0.2)
	collectSound.stream = collectSoundSFX.pick_random()
	collectSound.play()
	
func doTimers(delta:float) -> void:
	if goAwayTimer > 0:
		goAwayTimer -= delta
#UI
var prevhidden:bool
func gamepause(paused:bool) -> void:
	if paused:
		prevhidden = visible
		hide()
	else:
		visible = prevhidden
