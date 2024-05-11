extends CharacterBody3D

@export var camera:Camera3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
var _ACCEL:float = 1

var cameraDistance := 2.7
var scrollSpeed := 0.4
var mouseSens := 0.005
var visual_y_direction := 0.0

var camera_deg := Vector2(0,0)

@onready var springarm := $Pivot/Arm
@onready var pivot := $Pivot
@onready var visual := $Visual

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
	if global_position.y < -30:
		global_position = Vector3(0,2.778,-2.248)
	pivot.rotation.x = lerp(pivot.rotation.x,camera_deg[1],pow(_lerp_speed,0.2))
	pivot.rotation.y = lerp(pivot.rotation.y,camera_deg[0],pow(_lerp_speed,0.2))
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	var _lerp_speed:float = 1-pow(0.000000000005,delta)
	velocity.y -= gravity * delta

	if Input.is_action_pressed("movement_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
	
	var _pivot_rotation = pivot.rotation.x
	pivot.rotation.x = 0
	var direction:Vector3 = (pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	pivot.rotation.x = _pivot_rotation

	if direction:
		visual_y_direction = atan2(-direction.x, -direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y,visual_y_direction,_lerp_speed/2)
		velocity.x = move_toward(velocity.x,direction.x * SPEED,_ACCEL)
		velocity.z = move_toward(velocity.z,direction.z * SPEED,_ACCEL)
	else:
		velocity.x = move_toward(velocity.x, 0, _ACCEL)
		velocity.z = move_toward(velocity.z, 0, _ACCEL)
	
	move_and_slide()
	
func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			camera_deg += event.relative * -mouseSens
