extends Node3D

@export var bounceHeight := 2.5
@export var debounceTimer := 0.5

@export var bounceSound:AudioStreamPlayer3D
@export var area:Area3D
@export var debounce:Timer
@export var resource:springResource

var vardebounce := false
var bouncePower := 0.0

func _ready() -> void:
	area.body_entered.connect(onBounce)
	debounce.timeout.connect(on_debounce_done)
	
	debounce.wait_time = debounceTimer
	debounce.one_shot = true
	set_bounce_power(bounceHeight)

func set_bounce_power(height:float) -> void:
	bouncePower = ((2.0 * height) / 0.35)

func onBounce(body:Node3D) -> void:
	if vardebounce: return
	if not body.is_in_group("Player"): return
	
	body.springCombo += 1
	if body.springCombo == 1:
		body.jumpAnimation = 0.0
	body.springCombo = clampi(body.springCombo,0,6)
	body.baseDEACEL = 1.0
	
	vardebounce = true
	debounce.start()
	bounceSound.play()
	body.velocity.y = bouncePower
	body.jumpAnimation += 1.0
	if body.jumpAnimation >= 3.0 or body.jumpAnimation == -1.0:
		body.jumpAnimation = -555.0
	
	if body.state == 0:
		body.anim_st.travel("Jump")
	
	bounceSound.pitch_scale = float(body.springCombo)**0.1
	resource.on_bounce(self,area,body)
	pass

func on_debounce_done() -> void:
	vardebounce = false
