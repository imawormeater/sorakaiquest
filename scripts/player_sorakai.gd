extends CharacterBody3D

@export var camera:Camera3D

var SPEED := 5.0
var _ACCEL:float = 25.0
var _DEACCEL:float = 30.0

var JUMPHEIGHT := 2.5
var JUMPPEAKTIME := 0.5
var JUMPDESCENTTIME := 0.35

var jump_velo:float
var jump_grav:float
var fall_grav:float

var cameraDistance := 2.7
const scrollSpeed := 0.4
var mouseSens := 0.005
var visual_y_direction := 0.0

var camera_deg := Vector2(0,0)

var jumping := false

var DEACEL_mult := 1.0
#timers
var jumpbufferInit := 0.2
var jumpbuffer := -1.0
var coyotejumpInit := 0.2
var coyotejump := -1.0
var exitwallclimbinit := 0.5
var exitwallclimb := -1.0
var griptimerinit := 0.5
var griptimer := -1.0

enum States {Free, Wall, Hang}
var state:= States.Free

@onready var springarm := $Pivot/Arm
@onready var pivot := $Pivot
@onready var visual := $Visual
@onready var facecast := $Visual/faceCast
@onready var hang_frontCast := $Visual/hangCasts/FrontCast
@onready var hang_topCast := $Visual/hangCasts/TopCast

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = 16

func setCorrectJumpVariables():
	jump_velo = ((2.0 * JUMPHEIGHT) / JUMPPEAKTIME)
	jump_grav = ((-2.0 * JUMPHEIGHT) / (JUMPPEAKTIME * JUMPPEAKTIME))
	fall_grav= ((-2.0 * JUMPHEIGHT) / (JUMPDESCENTTIME* JUMPDESCENTTIME))
	
	print(jump_velo)
	print(jump_grav)
	print(fall_grav)
	

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	setCorrectJumpVariables()

func _process(delta: float) -> void:
	var _lerp_speed:float = 1-pow(0.000000000005,delta)
	camera_deg[1] = clamp(camera_deg[1],-PI/3,PI/3)
	
	if Input.is_action_just_released('mw_up'):
		cameraDistance -= scrollSpeed
	elif Input.is_action_just_released('mw_down'):
		cameraDistance += scrollSpeed
	cameraDistance = clamp(cameraDistance,1,5)	
	springarm.spring_length = lerp(springarm.spring_length,cameraDistance,_lerp_speed)
	if springarm.spring_length < 0.1:
		visual.visible = false
	else:
		visual.visible = true
	
	if Input.is_action_just_pressed('ui_cancel'):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if global_position.y < -10:
		global_position = Vector3(0,2.778,-2.248)
	pivot.rotation.x = lerp(pivot.rotation.x,camera_deg[1],pow(_lerp_speed,0.2))
	pivot.rotation.y = lerp(pivot.rotation.y,camera_deg[0],pow(_lerp_speed,0.2))
	

func do_timers(delta:float) -> void:
	if jumpbuffer > 0:
		jumpbuffer -= delta
	if coyotejump > 0:
		coyotejump -= delta
	if exitwallclimb > 0:
		exitwallclimb -= delta
	if griptimer > 0:
		griptimer -= delta

func getGravity(_pressingJump:bool) -> float:
	return jump_grav if velocity.y > 0.0 and _pressingJump else fall_grav

func jump() -> void:
	velocity.y = jump_velo
	exitwallclimb = 0.05
	griptimer = 0.05
	jumpbuffer = -1
	jumping = true
	
func checkHang() -> bool:
	if hang_frontCast.is_colliding() and hang_topCast.is_colliding():
		if hang_topCast.get_collision_normal() == Vector3.ZERO:
			return false
		return true
	return false
	
func hangInit() -> void:
	if checkHang() and griptimer < 0 and velocity.y != 0:
		var topPosition = hang_topCast.get_collision_point()
		var frontPosition = hang_frontCast.get_collision_point()
		visual.look_at(global_position - hang_frontCast.get_collision_normal())
		global_position = Vector3(frontPosition.x,topPosition.y - 0.5,frontPosition.z) + (visual.global_basis.z * 0.45)
		velocity = Vector3.ZERO
		state = States.Hang

func _physics_process(delta: float) -> void:
	do_timers(delta)
	var _lerp_speed:float = 1-pow(0.000000000005,delta)
	
	if state == States.Free:
		var onFloor := is_on_floor()
		
		var pressedJump = Input.is_action_just_pressed("movement_jump")
		var pressingJump = Input.is_action_pressed("movement_jump")

		velocity.y += getGravity(pressingJump) * delta
			
		if pressedJump:
			jumpbuffer = jumpbufferInit
			if coyotejump > 0:
				jump()
		if onFloor:
			DEACEL_mult = 1.0
			if jumpbuffer > 0:
				jump()
		
		var input_dir := Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
		
		var _pivot_rotation = pivot.rotation.x
		pivot.rotation.x = 0
		var direction:Vector3 = (pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		pivot.rotation.x = _pivot_rotation
		
		var _tempVelocity := Vector2(velocity.x,velocity.z)
		if direction:
			visual.rotation.y = lerp_angle(visual.rotation.y,atan2(-direction.x, -direction.z),_lerp_speed/2 * (DEACEL_mult)**2)
			_tempVelocity = _tempVelocity.move_toward(Vector2(direction.x,direction.z) * SPEED,_ACCEL * delta * DEACEL_mult)
		else:
			_tempVelocity = _tempVelocity.move_toward(Vector2.ZERO,_DEACCEL * delta * DEACEL_mult)
		velocity.x = _tempVelocity.x
		velocity.z = _tempVelocity.y
		
		velocity.y = clampf(velocity.y,fall_grav*JUMPDESCENTTIME*1.1,9999)
		move_and_slide()
		if onFloor != is_on_floor() and velocity.y < 0:#was on floor but now not
			coyotejump = coyotejumpInit
		if facecast.is_colliding() and velocity.y != 0 and exitwallclimb < 0:
			state = States.Wall
		hangInit()


	if state == States.Wall:
		var facecastnormal = facecast.get_collision_normal()
		visual.look_at(global_position - facecastnormal)
		velocity.y += jump_grav * 0.5 * delta
		velocity.y = clampf(velocity.y,jump_grav * 0.2,9999)
		var pressedJump = Input.is_action_just_pressed("movement_jump")
		move_and_slide()
		if pressedJump:
			visual.look_at(global_position + facecastnormal)
			state = States.Free
			DEACEL_mult = 0.5
			jump()
			velocity.x = facecastnormal.x * 7
			velocity.z = facecastnormal.z * 7
			return
		if not facecast.is_colliding() or is_on_floor():
			exitwallclimb = exitwallclimbinit
			state = States.Free
			return
		hangInit()
			
	if state == States.Hang:
		var frontcastnormal = hang_frontCast.get_collision_normal()
		var pressedJump = Input.is_action_just_pressed("movement_jump")
		visual.look_at(global_position - frontcastnormal)
		if not checkHang():
			griptimer = griptimerinit
			state = States.Free
			return
		if pressedJump:
			state = States.Free
			jump()
			griptimer = griptimerinit
		
	
func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			camera_deg += event.relative * -mouseSens
