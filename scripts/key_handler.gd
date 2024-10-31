extends Equipable

var launchPower:float = 5
var canUse:bool = false
var debounce:float = 1

var ogPos:Vector3 = Vector3.ZERO
var ogParent:Node3D = null
@onready var rigidBody:RigidBody3D = $RigidBody3D
@onready var keyCollision:CollisionShape3D = $RigidBody3D/keyCollision
@onready var throwSound:AudioStreamPlayer3D = $RigidBody3D/throw

func _ready() -> void:
	ogPos = self.global_position
	ogParent = self.get_parent_node_3d()
	GameManager.CurrentState.new_level_loaded.connect(onlevelLoaded)
	if rigidBody == null:
		self.queue_free()
		return
	rigidBody.top_level = false
	rigidBody.sleeping = true
	rigidBody.freeze = true

func onEquip() -> void:
	sorakai = GameManager.CurrentState.Sorakai
	canUse = false
	
	interactable.enabled = false
	rigidBody.top_level = false
	rigidBody.sleeping = true
	rigidBody.freeze = true
	
	sorakai.equip(self)
	rigidBody.position = Vector3.ZERO
	
	await get_tree().create_timer(0.2).timeout
	canUse = true
	
func onUse() -> void:
	if(!canUse): return
	sorakai.unequip()

func revert() -> void:
	canUse = false
	rigidBody.sleeping = true
	interactable.enabled = true

func _physics_process(_delta: float) -> void:
	if sorakai == null: return

func onUnequip() -> void:
	if interactable == null:
		self.queue_free()
		return
	if sorakai:
		rigidBody.linear_velocity = -sorakai.visual.global_transform.basis.z * launchPower + sorakai.velocity
		rigidBody.linear_velocity.y += launchPower
	sorakai = null
	rigidBody.sleeping = false
	rigidBody.top_level = true
	rigidBody.freeze = false
	throwSound.play(0.65)
	await get_tree().create_timer(0.4).timeout
	interactable.enabled = true
	
func onlevelLoaded() -> void:
	rigidBody.top_level = false
	rigidBody.sleeping = true
	rigidBody.freeze = true
	interactable.enabled = true
	if self.is_inside_tree():#this might cause a memory leak? idk
		global_position = ogPos
		rigidBody.global_position = ogPos
		reparent(ogParent)
	if ogParent == null:
		self.queue_free()


func _on_key_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("deathPlane"):
		onlevelLoaded()
