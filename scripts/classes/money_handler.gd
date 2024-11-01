class_name MoneyHandler
extends Node3D

var kromer:Array[moneyCollectable] = []
var _rotation:float = 0

func _ready() -> void:
	for i:Node3D in get_children():
		_checkAndAppendDollar(i)
	
	await get_tree().create_timer(0.1).timeout
	GameManager.CurrentState.new_level_loaded.connect(levelLoaded)
		
	
func levelLoaded() -> void:
	kromer.clear()
	for i:Node3D in get_children():
		_checkAndAppendDollar(i)

func _physics_process(delta: float) -> void:
	_rotation = fmod(_rotation + delta,2*PI)
	for i:moneyCollectable in kromer:
		if GameManager.CurrentState.Sorakai == null:
			return
		if i != null:
			_moneyUpdate(i,GameManager.CurrentState.Sorakai.global_position)


func _on_child_exiting_tree(node: Node) -> void:
	if node in kromer:
		kromer.erase(node)


func _checkAndAppendDollar(i:Node3D) -> void:
	if i is moneyCollectable:
		var m:moneyCollectable = i as moneyCollectable
		if !m in kromer:
			kromer.append(m)
	
func _moneyUpdate(m:moneyCollectable,playerPosition:Vector3) -> void:
	if (m.global_position-playerPosition).length() > 30:
		m.visible = false
		return
	m.visible = true
	m.visual.position.y = sin(GameManager.sinTick*2)/9
	m.visual.rotation.y = _rotation
