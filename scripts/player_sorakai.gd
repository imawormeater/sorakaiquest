extends CharacterBody3D

@export var camera:Camera3D

@export var controlOn := true #sets player controls
@export var cameraOn := true #gets rid of camera controls
@export var disabledCamera := false #stops setting camera

#GAMEPLAY SHIT

@export var baseSPEED := 5.0
var SPEED := baseSPEED
@export var _ACCEL:float = 25.0
@export var _DEACCEL:float = 30.0

var DEACEL_mult := 1.0
var baseDEACEL := 1.0

var SNAPLENGTH := 0.1

#JUMP SHIT

@export var JUMPHEIGHT := 2.5
@export var JUMPPEAKTIME := 0.5
@export var JUMPDESCENTTIME := 0.35

var jump_velo:float
var jump_grav:float
var fall_grav:float

#CAMERA SHIT
var cameraDistance := 2.7
const scrollSpeed := 0.4
var mouseSens := 0.005
var visual_y_direction := 0.0
var camera_deg := Vector2(0,0)
var old_camera_pos := Vector3.ZERO
#TIMER SHIT
const jumpbufferInit := 0.2
var jumpbuffer := -1.0
const coyotejumpInit := 0.2
var coyotejump := -1.0
const exitwallclimbinit := 0.5
var exitwallclimb := -1.0
const griptimerinit := 0.5
var griptimer := -1.0

var wallconcetioncount := 0.0

var wallrideDebounce := -1.0
const wallrideInit := 0.2
var wallrideTimer := 0.0
const WRtilJump := 0.05

var jumpTimer := 0.0
#STATE SHIT
enum States {Free, Wall, Hang, WallRun, Roll, Noclip}
var state:= States.Free

var wallRideCast:RayCast3D 
var wallRideMag:float
var forcedHoldJump := false
#OTHER SHIT
var springCombo := 0
var jumpAnimation := 1.0
@export var dying := true
#

@onready var springarm := $Pivot/Arm
@onready var pivot := $Pivot
@onready var visual := $Visual

@onready var facecast := $Visual/faceCast
@onready var hang_frontCast := $Visual/hangCasts/FrontCast
@onready var hang_topCast := $Visual/hangCasts/TopCast 
@onready var leftCast := $Visual/wallCasts/left
@onready var rightCast := $Visual/wallCasts/right

@onready var character := $Visual/loganchara
@onready var character_mesh := $Visual/loganchara/Armature/Skeleton3D/logan
@onready var targetCamera := $Pivot/Arm/Target

@onready var animationtree := $Visual/loganchara/AnimationTree
@onready var walkDust := $Visual/WalkDust
@onready var sfx := $PlayerSFX
@onready var followPoint := $Visual/loganchara/FollowPoint

@export var _face_mat: String
@onready var face:ShaderMaterial = character_mesh.get(_face_mat)

@export var faces_textures := {
	"normal" : preload("res://assets/images/loganchara_loganface1.png"),
	"blink" : preload("res://assets/images/loganface2.png")
}

var anim_st:AnimationNodeStateMachinePlayback

var currentKey:Node3D

func setCorrectJumpVariables() -> void:
	jump_velo = ((2.0 * JUMPHEIGHT) / JUMPPEAKTIME)
	jump_grav = ((-2.0 * JUMPHEIGHT) / (JUMPPEAKTIME * JUMPPEAKTIME))
	fall_grav= ((-2.0 * JUMPHEIGHT) / (JUMPDESCENTTIME* JUMPDESCENTTIME))

func setJumpAnimation() -> void:
	jumpAnimation = absf(fmod(jumpAnimation,2.0))

func changeFace(whichface:String) -> void:
	var currentface:CompressedTexture2D = faces_textures[whichface]
	if currentface == null:
		face["shader_parameter/Texture"] = faces_textures["normal"]
	face["shader_parameter/Texture"] = currentface

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	springarm.add_excluded_object(self)
	setCorrectJumpVariables()
	animationtree.active = true
	anim_st = animationtree.get("parameters/playback")
	
	for key in get_tree().get_nodes_in_group("Keys"):
		key.key_touched.connect(key_touched)
	
	for lockedDoor in get_tree().get_nodes_in_group("LockedDoors"):
		lockedDoor.lockedDoor_touched.connect(lockedDoor_touched)
		
	await get_tree().create_timer(0.5,false).timeout #invincibility when respawn
	dying = false

func _process(delta: float) -> void:#Camera shit
	if OS.is_debug_build():
			if Input.is_action_just_pressed("debug1") and state != States.Noclip:
				state = States.Noclip
	if disabledCamera: return
	
	var _lerp_speed:float = 1-pow(0.000000000005,delta)
	camera_deg[1] = clamp(camera_deg[1],-PI/3,PI/3)
	
	if cameraOn:
		if Input.is_action_just_released('mw_up'):
			cameraDistance -= scrollSpeed
		elif Input.is_action_just_released('mw_down'):
			cameraDistance += scrollSpeed
			
	cameraDistance = clamp(cameraDistance,1.4,5)	
	springarm.spring_length = lerp(springarm.spring_length,cameraDistance,_lerp_speed)
	if springarm.spring_length < 0.1:
		visual.visible = false
	else:
		visual.visible = true
	
	if Input.is_action_just_pressed('camera_unlock'):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#if global_position.y < -10:
	#	global_position = Vector3(0,2.778,-2.248)
	pivot.rotation.x = lerp(pivot.rotation.x,camera_deg[1],_lerp_speed**0.2)
	pivot.rotation.y = lerp(pivot.rotation.y,camera_deg[0],_lerp_speed**0.2)
	
	camera.global_transform = camera.global_transform.interpolate_with(targetCamera.global_transform,_lerp_speed)
	
	if currentKey:
		currentKey.global_transform = currentKey.global_transform.interpolate_with(followPoint.global_transform,_lerp_speed * 0.2)
	

func do_timers(delta:float) -> void: ##Does the Timers
	if jumpbuffer > 0:
		jumpbuffer -= delta
	if coyotejump > 0:
		coyotejump -= delta
	if exitwallclimb > 0:
		exitwallclimb -= delta
	if griptimer > 0:
		griptimer -= delta
	if wallrideDebounce > 0:
		wallrideDebounce -= delta

func getGravity(_pressingJump:bool) -> float:
	if velocity.y < 0.0:
		forcedHoldJump = false
	return jump_grav if (velocity.y > 0.0 and _pressingJump) or forcedHoldJump else fall_grav

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
	sfx.play_sound("Jump")
	jumpAnimation += 1.0
	#if jumpAnimation >= 3.0:
		#jumpAnimation = -555.0
	jumpTimer = 0.0
	
#CHECKS FOR HANG STATE
func checkHang() -> bool:
	if hang_frontCast.is_colliding() and hang_topCast.is_colliding():
		if hang_topCast.get_collision_normal() == Vector3.ZERO:
			return false
		return true
	return false
	
#INITATES STATES
func wallInit(_delta:float) -> void:
	if facecast.is_colliding() and velocity.y != 0 and exitwallclimb < 0:
		if absf(facecast.get_collision_normal().y) < 0.2:
			wallconcetioncount += _delta
			if wallconcetioncount > 0.05:
				SPEED = baseSPEED
				state = States.Wall
				#print("Change State Wall")
				anim_st.travel("OnWallStart")
				sfx.play_sound_into("Wallridebegin","Walkriding")
	else:
		wallconcetioncount = 0.0
		
func hangInit() -> void:
	if checkHang() and griptimer < 0 and velocity.y != 0:
		var frontNORMAL:Vector3 = hang_frontCast.get_collision_normal()
		var topNORMAL:Vector3 = hang_topCast.get_collision_normal()
		if absf(frontNORMAL.y) < 0.2 and absf(topNORMAL.x) < 0.3:
			var topPosition:Vector3 = hang_topCast.get_collision_point()
			var frontPosition:Vector3 = hang_frontCast.get_collision_point()
			visual.look_at(global_position - frontNORMAL)
			global_position = Vector3(frontPosition.x,topPosition.y - 0.5,frontPosition.z) + (visual.global_basis.z * 0.45)
			if not hang_topCast.is_colliding() or not hang_frontCast.is_colliding():
				return
			velocity = Vector3.ZERO
			SPEED = baseSPEED
			state = States.Hang
			baseDEACEL = 1.0
			jumpAnimation = 1.0
			anim_st.travel("Grab")
			sfx.play_sound("Grab")
			#print("Change State Grab")
			
func wallRunInit(veloMag:float) -> void:
	character_mesh.rotation.y = 0
	character_mesh.scale = Vector3.ONE
	
	if wallrideDebounce >= 0: return
	if veloMag < 1: return
	
	if leftCast.is_colliding(): 
		wallRideCast = leftCast
		character_mesh.scale = Vector3(1,1,-1)
		character_mesh.rotation.y = PI/4
	elif rightCast.is_colliding(): 
		wallRideCast = rightCast
		character_mesh.rotation.y = -PI/4
	else:
		character_mesh.rotation.y = 0 
		return
	
	wallrideTimer = 0
	wallRideMag = veloMag
	state = States.WallRun
	
	var wallNormal = wallRideCast.get_collision_normal()
	var foward := wallNormal.cross(visual.global_basis.y) * wallRideMag
	if (-visual.global_basis.z - foward).length() > (-visual.global_basis.z - -foward).length():
		foward = -foward
	velocity = Vector3(foward.x,velocity.y,foward.z)

	wallrideDebounce = -1.
	sfx.play_sound("Wallride")
	anim_st.travel("Wallrun")
#
func get_pitch(normal:Vector3) -> float:
	return asin(normal.cross(visual.global_basis.x).y)

#MOST ANIMATIONS FUNCTION
func set_animations(onfloor:bool,_state:int,veloMag:float) -> void:
	var _velocity := veloMag/baseSPEED
	var curanim := anim_st.get_current_node()
	var stepsound:AudioStreamPlayer3D = sfx.get_sound("Steps")
	animationtree["parameters/IdleWalk/animation/blend_position"] = Vector2(_velocity,0)
	animationtree["parameters/conditions/onFloor"] = onfloor
	animationtree["parameters/conditions/Fall"] = not onfloor
	animationtree["parameters/conditions/OnWall"] = false
	animationtree["parameters/Jump/BlendSpace1D/blend_position"] = (jumpAnimation - 1.)
	
	if _state == States.Wall:
		animationtree["parameters/conditions/OnWall"] = true
	
	animationtree["parameters/IdleWalk/TimeScale/scale"] = sqrt(_velocity)
	animationtree["parameters/Wallrun/TimeScale/scale"] = sqrt(_velocity)
	if animationtree["parameters/IdleWalk/animation/blend_position"].x < 0.1:
		animationtree["parameters/IdleWalk/TimeScale/scale"] = 1.0
	
	if (curanim != "IdleWalk") and onfloor:
		springCombo = 0
		anim_st.travel("Land")
		sfx.play_sound("Land")
	if (curanim.begins_with("OnWall")) and not animationtree["parameters/conditions/OnWall"]:
		anim_st.travel("Fall")
	
	if _velocity == 0 or not onfloor:
		walkDust.emitting = false
		sfx.stop_sound("Steps")
	else:
		stepsound.pitch_scale = sqrt(_velocity) * 0.82
		if stepsound.playing == false:
			sfx.play_sound("Steps")
		walkDust.emitting = true

#MOMENTUM
func set_momentum(pitch:float,delta:float,onFloor:bool,direction:Vector2,veloMag:float) -> void:
	var hill:int = 0
	var _velocity:float = veloMag/baseSPEED
	if direction != Vector2.ZERO:
		hill = -1
	var momentum:float = pitch * hill
	SPEED += momentum * delta * 5
	if SPEED < 5:
		SPEED =  clampf(SPEED,baseSPEED-absf(momentum)*2,999)
	SNAPLENGTH = 0.15 * (SPEED/baseSPEED)
	
	var lerpSpeed:float =  clampf((_velocity**2),1,999) * 5
	#print(lerpSpeed,"  ",_velocity)
	if _velocity < 1.0:
		lerpSpeed = 100
	if _velocity < 0.3:
		SPEED = move_toward(SPEED,baseSPEED,delta * 100)
	
	if momentum == 0.0 and onFloor:
		SPEED = move_toward(SPEED,baseSPEED,delta * lerpSpeed)
	DEACEL_mult = sqrt(baseSPEED/SPEED) * baseDEACEL

#EVERYTHING
func _physics_process(delta: float) -> void:
	do_timers(delta)
	var _lerp_speed:float = 1-pow(0.000000000005,delta)
	floor_snap_length = SNAPLENGTH
	
	var onFloor := is_on_floor()
	var input_dir := Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
	var pressedJump := Input.is_action_just_pressed("movement_jump")
	var pressingJump := Input.is_action_pressed("movement_jump")
	var pressedAction := Input.is_action_pressed("movement_action")
	var velocityMag := Vector2(velocity.x,velocity.z).length()
	if not controlOn:
		pressingJump = false
		pressedAction = false
		pressedJump = false
		input_dir = Vector2.ZERO
		
	set_animations(onFloor,state,velocityMag)
	
	if pressingJump:
		changeFace('blink')
	else:
		changeFace('normal')
	#FREE STATE (RUNNING, JUMPING, BASIC)
	
	if state == States.Free:
		var pitch := get_pitch(get_floor_normal())
		set_momentum(pitch,delta,onFloor,input_dir,velocityMag)
		
		velocity.y += getGravity(pressingJump) * delta
		character.rotation.z = lerp_angle(character.rotation.z,pitch/2,_lerp_speed*0.2)

		if pressedJump:
			jumpbuffer = jumpbufferInit
			if coyotejump > 0:
				setJumpAnimation()
				jump()
		if onFloor:
			setJumpAnimation()
			baseDEACEL = 1.0
			jumpTimer = 0.0
			if jumpbuffer > 0:
				jump()
		else:
			jumpTimer += delta
		var _pivot_rotation:float = pivot.rotation.x
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
		if jumpbuffer > 0 and not is_on_floor() and jumpTimer > WRtilJump:
			wallRunInit(Vector2(velocity.x,velocity.z).length())
		wallInit(delta)
		hangInit()

	#WALL RIDE STATE
	if state == States.Wall:
		var facecastnormal:Vector3 = facecast.get_collision_normal()

		visual.look_at(global_position - facecastnormal)
		velocity.y += jump_grav * 0.5 * delta
		velocity.y = clampf(velocity.y,jump_grav * 0.2,9999)
		move_and_slide()
		if pressedJump or jumpbuffer > 0:
			sfx.stop_sound("Walkriding")
			sfx.stop_sound("Wallridebegin")
			visual.look_at(global_position + facecastnormal)
			state = States.Free
			baseDEACEL = 0.5
			jump()
			velocity.x = facecastnormal.x * 7
			velocity.z = facecastnormal.z * 7
			animationtree["parameters/conditions/OnWall"] = false
			anim_st.travel("Jump")
			return
		if not facecast.is_colliding() or is_on_floor() or pressedAction:
			sfx.stop_sound("Walkriding")
			sfx.stop_sound("Wallridebegin")
			exitwallclimb = exitwallclimbinit
			state = States.Free
			visual.rotation.x = 0
			visual.rotation.z = 0
			animationtree["parameters/conditions/OnWall"] = false
			return
		hangInit()
			
			
	#HANG STATE
	
	if state == States.Hang:
		var frontcastnormal:Vector3 = hang_frontCast.get_collision_normal()
		if frontcastnormal.dot(Vector3.UP) > 0.001:
			visual.look_at(global_position - frontcastnormal)
		exitwallclimb = 0.5
		if not checkHang() or pressedAction:
			griptimer = griptimerinit
			state = States.Free
			visual.rotation.x = 0
			visual.rotation.z = 0
			anim_st.travel("Fall")
			return
		if pressedJump or jumpbuffer > 0:
			state = States.Free
			jump()
			griptimer = griptimerinit
	
	#WALL RUN
	if state == States.WallRun:
		wallrideTimer += delta
		
		var wallNormal = wallRideCast.get_collision_normal()
		var foward := wallNormal.cross(visual.global_basis.y) 
		if (-visual.global_basis.z - foward).length() > (-visual.global_basis.z - -foward).length():
			foward = -foward
		foward *= wallRideMag
		velocity = Vector3(foward.x,velocity.y,foward.z) + (-wallNormal)
		velocity.y += jump_grav * 0.7 * delta
		velocity.y = clampf(velocity.y,jump_grav * 0.4,9999)
		
		visual.look_at(global_position + foward)
		move_and_slide()
		if not wallRideCast.is_colliding() or is_on_floor() or velocityMag < 1 or foward.length() == 0 or pressedAction:
			character_mesh.scale = Vector3.ONE
			character_mesh.rotation = Vector3.ZERO
			state = States.Free
			wallrideDebounce = wallrideInit
			anim_st.travel("Fall")
		if not pressingJump:
			character_mesh.scale = Vector3.ONE
			character_mesh.rotation = Vector3.ZERO
			state = States.Free
			wallrideDebounce = wallrideInit
			forcedHoldJump = true
			jump()
			velocity += (wallNormal*5)
			baseDEACEL = 0.45
		
	if state == States.Noclip:
		var direction:Vector3 = (pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * 10
		global_position += direction * delta
		if pressingJump:
			global_position.y += 10 * delta
		if pressedAction:
			global_position.y -= 10 * delta
		if Input.is_action_just_pressed('debug2'):
			velocity = Vector3.ZERO
			state = States.Free

func _input(event) -> void:
	if event is InputEventMouseMotion:
		if cameraOn or disabledCamera:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				camera_deg += event.relative * -mouseSens

func die() -> void:
	dying = true
	controlOn = false
	cameraOn = false
	disabledCamera = true
	sfx.play_sound("Die")

func key_touched(key) -> void:
	if not currentKey:
		currentKey = key
		sfx.play_sound("Pickup")
	
func lockedDoor_touched(door) -> void:
	if currentKey:
		currentKey.queue_free()
		door.queue_free()
		
		currentKey = null

func refresh() -> void:
	currentKey = null
	
	for key in get_tree().get_nodes_in_group("Keys"):
		key.key_touched.connect(key_touched)
	
	for lockedDoor in get_tree().get_nodes_in_group("LockedDoors"):
		lockedDoor.lockedDoor_touched.connect(lockedDoor_touched)
