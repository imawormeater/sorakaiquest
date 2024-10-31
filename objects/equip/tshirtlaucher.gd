extends Equipable

var launchPower:float = 20
var canUse:bool = true
var used:bool = false

var ogPos:Vector3 = Vector3.ZERO
var ogParent:Node3D = null

func _ready() -> void:
	ogPos = self.global_position
	ogParent = self.get_parent_node_3d()
	GameManager.CurrentState.new_level_loaded.connect(onUnequip)

func onEquip() -> void:
	sorakai = GameManager.CurrentState.Sorakai
	sorakai.equip(self)
	interactable.enabled = false
	
func onUse() -> void:
	if(!canUse): return
	canUse = false
	used = true
	sorakai.jump()
	sorakai.DEACEL_mult = 0.1
	sorakai.velocity += get_viewport().get_camera_3d().transform.basis.z * launchPower

func revert() -> void:
	canUse = true
	used = false
	sorakai.cantHoldJump = false

func _physics_process(_delta: float) -> void:
	if sorakai == null: return
	if(sorakai.is_on_floor()):
		revert()
	if(used):
		sorakai.cantHoldJump = true
		sorakai.DEACEL_mult = 0.1
	if(sorakai.state == sorakai.States.WallRun):
		revert()

func onUnequip() -> void:
	interactable.enabled = true
	sorakai = null
	canUse = false
	used = false
	if self.is_inside_tree():#this might cause a memory leak? idk
		global_position = ogPos
		reparent(ogParent)
	if ogParent == null:
		self.queue_free()
