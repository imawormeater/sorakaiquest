extends CharacterBody3D

@export var camera:Camera3D

var baseSPEED := 5.0
var SPEED := baseSPEED
var _ACCEL:float = 25.0
var _DEACCEL:float = 30.0
var DEACEL_mult := 1.0
var SNAPLENGTH := 0.1
#JUMP SHIT
var JUMPHEIGHT := 2.5
var JUMPPEAKTIME := 0.5
var JUMPDESCENTTIME := 0.35

var jump_velo:float
var jump_grav:float
var fall_grav:float
#CAMERA SHIT
var cameraDistance := 2.7
const scrollSpeed := 0.4
var mouseSens := 0.005
var visual_y_direction := 0.0
var camera_deg := Vector2(0,0)

#timers
var jumpbufferInit := 0.2
var jumpbuffer := -1.0
var coyotejumpInit := 0.2
var coyotejump := -1.0
var exitwallclimbinit := 0.5
var exitwallclimb := -1.0
var griptimerinit := 0.5
var griptimer := -1.0
#STATE SHIT
enum States {Free, Wall, Hang}
var state:= States.Free

@onready var springarm := $Pivot/Arm
@onready var pivot := $Pivot
@onready var visual := $Visual
@onready var facecast := $Visual/faceCast
@onready var hang_frontCast := $Visual/hangCasts/FrontCast
@onready var hang_topCast := $Visual/hangCasts/TopCast 
@onready var character := $Visual/loganchara

@onready var animationtree := $Visual/loganchara/AnimationTree
@onready var walkDust = $Visual/WalkDust
var anim_st

func setCorrectJumpVariables():
	jump_velo = ((2.0 * JUMPHEIGHT) / JUMPPEAKTIME)
	jump_grav = ((-2.0 * JUMPHEIGHT) / (JUMPPEAKTIME * JUMPPEAKTIME))
	fall_grav= ((-2.0 * JUMPHEIGHT) / (JUMPDESCENTTIME* JUMPDESCENTTIME))
	
	print(jump_velo)
	print(jump_grav)
	print(fall_grav)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	springarm.add_excluded_object(self)
	setCorrectJumpVariables()
	anim_st = animationtree.get("parameters/playback")

func _process(delta: float) -> void:#Camera shit
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
	

func do_timers(delta:float) -> void: ##Does the Timers
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

#JUMP
func jump() -> void:
	floor_snap_length = 0.1
	velocity.y = jump_velo
	exitwallclimb = 0.1
	griptimer = 0.05
	jumpbuffer = -1
	visual.rotation.x = 0
	visual.rotation.z = 0
	anim_st.travel("Jump")
	
#CHECKS FOR HANG STATE
func checkHang() -> bool:
	if hang_frontCast.is_colliding() and hang_topCast.is_colliding():
		if hang_topCast.get_collision_normal() == Vector3.ZERO:
			return false
		return true
	return false
#INITATES HANG STATE
func hangInit() -> void:
	if checkHang() and griptimer < 0 and velocity.y != 0:
		var frontNORMAL:Vector3 = hang_frontCast.get_collision_normal()
		var topNORMAL:Vector3 = hang_topCast.get_collision_normal()
		if absf(frontNORMAL.y) < 0.2 and absf(topNORMAL.x) < 0.3:
			var topPosition = hang_topCast.get_collision_point()
			var frontPosition = hang_frontCast.get_collision_point()
			visual.look_at(global_position - frontNORMAL)
			global_position = Vector3(frontPosition.x,topPosition.y - 0.5,frontPosition.z) + (visual.global_basis.z * 0.45)
			velocity = Vector3.ZERO
			SPEED = baseSPEED
			state = States.Hang
			DEACEL_mult = 1.0
			anim_st.travel("Grab")
			print("Change State Grab")

func get_pitch(normal:Vector3) -> float:
	return asin(normal.cross(visual.global_basis.x).y)

#MOST ANIMATIONS FUNCTION
func set_animations(onfloor:bool,_state:int):
	var _velocity = sqrt(velocity.x**2 + velocity.z**2)/baseSPEED
	var curanim = anim_st.get_current_node()
	animationtree["parameters/IdleWalk/blend_position"] = Vector2(_velocity,0)
	animationtree["parameters/conditions/onFloor"] = onfloor
	animationtree["parameters/conditions/Fall"] = not onfloor
	animationtree["parameters/conditions/OnWall"] = false
	
	if _state == States.Wall:
		animationtree["parameters/conditions/OnWall"] = true
	
	if (curanim == "Fall" or curanim == "OnWall") and onfloor:
		anim_st.travel("Land")
	if curanim == "OnWall" and not animationtree["parameters/conditions/OnWall"]:
		anim_st.travel("Fall")
	
	if _velocity == 0 or not onfloor:
		walkDust.emitting = false
	else:
		walkDust.emitting = true

#MOMENTUM
func set_momentum(pitch:float,delta:float,onFloor:bool,direction:Vector2) -> void:
	var hill = 0
	if direction != Vector2.ZERO:
		hill = -1
	var momentum = pitch * hill
	SPEED += momentum * delta * 5
	SPEED =  clampf(SPEED,baseSPEED-absf(momentum)*2,999)
	SNAPLENGTH = 0.1 * (SPEED/baseSPEED)
		
	if momentum == 0.0 and onFloor:
		SPEED = move_toward(SPEED,baseSPEED,delta * 5)

#EVERYTHING
func _physics_process(delta: float) -> void:
	do_timers(delta)
	var _lerp_speed:float = 1-pow(0.000000000005,delta)
	floor_snap_length = SNAPLENGTH
	
	var onFloor := is_on_floor()
	var input_dir := Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
	var pressedJump := Input.is_action_just_pressed("movement_jump")
	var pressingJump := Input.is_action_pressed("movement_jump")
		
	set_animations(onFloor,state)
	
	#FREE STATE (RUNNING, JUMPING, BASIC)
	
	if state == States.Free:
		
		var pitch := get_pitch(get_floor_normal())
		set_momentum(pitch,delta,onFloor,input_dir)
		
		velocity.y += getGravity(pressingJump) * delta
		#character.rotation.z = pitch
		if pressedJump:
			jumpbuffer = jumpbufferInit
			if coyotejump > 0:
				jump()
		if onFloor:
			DEACEL_mult = 1.0
			if jumpbuffer > 0:
				jump()
		
		var _pivot_rotation = pivot.rotation.x
		pivot.rotation.x = 0
		var direction:Vector3 = (pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		pivot.rotation.x = _pivot_rotation
			
		var _tempVelocity := Vector2(velocity.x,velocity.z)
		if direction:
			visual.rotation.y = lerp_angle(visual.rotation.y,atan2(-direction.x, -direction.z),_lerp_speed/2 * (DEACEL_mult)**2)
			_tempVelocity = _tempVelocity.move_toward(Vector2(direction.x,direction.z) * SPEED ,_ACCEL * delta * DEACEL_mult)
		else:
			_tempVelocity = _tempVelocity.move_toward(Vector2.ZERO,_DEACCEL * delta * DEACEL_mult)
		velocity.x = _tempVelocity.x
		velocity.z = _tempVelocity.y
		
		velocity.y = clampf(velocity.y,fall_grav*JUMPDESCENTTIME*1.1,9999)
		move_and_slide()
		if onFloor != is_on_floor() and velocity.y < 0:#was on floor but now not
			coyotejump = coyotejumpInit
		if facecast.is_colliding() and velocity.y != 0 and exitwallclimb < 0:
			if absf(facecast.get_collision_normal().y) < 0.2:
				SPEED = baseSPEED
				state = States.Wall
				print("Change State Wall")
				anim_st.travel("OnWall")
		hangInit()


	#WALL RIDE STATE
	if state == States.Wall:
		var facecastnormal = facecast.get_collision_normal()

		visual.look_at(global_position - facecastnormal)
		velocity.y += jump_grav * 0.5 * delta
		velocity.y = clampf(velocity.y,jump_grav * 0.2,9999)
		move_and_slide()
		if pressedJump:
			visual.look_at(global_position + facecastnormal)
			state = States.Free
			DEACEL_mult = 0.5
			jump()
			velocity.x = facecastnormal.x * 7
			velocity.z = facecastnormal.z * 7
			animationtree["parameters/conditions/OnWall"] = false
			anim_st.travel("Jump")
			return
		if not facecast.is_colliding() or is_on_floor():
			exitwallclimb = exitwallclimbinit
			state = States.Free
			visual.rotation.x = 0
			visual.rotation.z = 0
			animationtree["parameters/conditions/OnWall"] = false
			return
		hangInit()
			
			
	#HANG STATE
	
	if state == States.Hang:
		var frontcastnormal = hang_frontCast.get_collision_normal()
		visual.look_at(global_position - frontcastnormal)
		exitwallclimb = 0.5
		if not checkHang():
			griptimer = griptimerinit
			state = States.Free
			visual.rotation.x = 0
			visual.rotation.z = 0
			return
		if pressedJump:
			state = States.Free
			jump()
			griptimer = griptimerinit
		
	
func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			camera_deg += event.relative * -mouseSens
