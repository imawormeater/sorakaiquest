extends Equipable

var launchPower:float = 20
var canUse:bool = true
var used:bool = false

var ogPos:Vector3 = Vector3.ZERO
var ogParent:Node3D = null

@onready var shoot:AudioStreamPlayer3D = $shoot
@onready var visual:Node3D = $Visual
@onready var timer:Timer = $Timer

@onready var p1:GPUParticles3D = $Visual/CollectSparkle
@onready var p2:GPUParticles3D = $Visual/CollectSparkle/Ring

func _ready() -> void:
	ogPos = self.global_position
	ogParent = self.get_parent_node_3d()
	GameManager.CurrentState.new_level_loaded.connect(onUnequip)

func onEquip() -> void:
	sorakai = GameManager.CurrentState.Sorakai
	sorakai.equip(self)
	sorakai.onJump.connect(_onjumpyeah)
	sorakai.canWall = false
	interactable.enabled = false
	
func onUse() -> void:
	if(!canUse): return
	if sorakai.state != sorakai.States.Free:
		sorakai.jump()
		sorakai.state = sorakai.States.Free
	canUse = false
	used = true
	sorakai.DEACEL_mult = 0.1
	sorakai.velocity += get_viewport().get_camera_3d().transform.basis.z * launchPower
	shoot.play()
	p1.emitting = true
	p2.emitting = true

func revert() -> void:
	canUse = true
	used = false
	sorakai.cantHoldJump = false

func _onjumpyeah() -> void:
	canUse = true

func _physics_process(_delta: float) -> void:
	if sorakai == null: return
	if(sorakai.is_on_floor()):
		sorakai.cantHoldJump = false
		used = false
	if(used):
		sorakai.cantHoldJump = true
		sorakai.DEACEL_mult = 0.1
	if(sorakai.state == sorakai.States.WallRun):
		revert()

func onUnequip() -> void:
	interactable.enabled = true
	if sorakai:
		sorakai.onJump.disconnect(_onjumpyeah)
		sorakai.canWall = true
		sorakai.cantHoldJump = false
	sorakai = null
	canUse = false
	used = false
	if self.is_inside_tree():#this might cause a memory leak? idk
		global_position = ogPos
		reparent(ogParent)
	if ogParent == null:
		self.queue_free()
