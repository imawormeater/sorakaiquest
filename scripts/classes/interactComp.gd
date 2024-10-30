class_name interactComp
extends Node

@export var objectDepedency:Node3D
@export var functionName:String = "on_interact"
var canInteract:bool = false
var enabled:bool = true

@onready var visible:VisibleOnScreenNotifier3D = $Visible
@onready var area3D:Area3D = $Area3D
@onready var hitbox:CollisionShape3D = $Area3D/Hitbox
@onready var interactVisual:Node3D = $InteractVisual


func _ready() -> void:
	area3D.body_entered.connect(onBodyEntered)
	area3D.body_exited.connect(onBodyLeft)
	$InteractVisual/Stars/AnimationPlayer.play("new_animation")

func interact() -> void:
	if not enabled: return
	objectDepedency.call_deferred(functionName)
	canInteract = true
	enabled = false

func onBodyEntered(body:Node3D) -> void:
	#print(body)
	if body is Logan:
		canInteract = true

func onBodyLeft(body:Node3D) -> void:
	#print(body)
	if body is Logan:
		canInteract = false

func _physics_process(_delta: float) -> void:
	interactVisual.visible = (canInteract && enabled)
	if canInteract && enabled:
		if Input.is_action_just_pressed("interact"):
			interact()
