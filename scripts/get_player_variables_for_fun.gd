extends CanvasLayer

@onready var label := $Label
@export var logan:CharacterBody3D

var is_debug:bool = true
var prevhidden:bool

func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	GameManager.CurrentState.albumCollected.connect(onAlbumCollect)
	if not OS.is_debug_build():
		is_debug = false
		label.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_page_down"):
		is_debug = !is_debug
		label.visible = is_debug
	if is_debug:
		var format_string:String = "velocity:%s\nspeed:%s\nstate:%s\naccel_mult:%s\nposition:%s\nhp:%s"
		var actual_string := format_string % [logan.velocity, logan.SPEED,logan.state,logan.DEACEL_mult,logan.global_position,1]
		label.text = actual_string

func onAlbumCollect(this:Node3D) -> void:
	$AlbumCollectControl.visible = true
	await get_tree().create_timer(GameManager.CurrentState.timeToCollect).timeout
	$AlbumCollectControl.visible = false

func gamepause(paused:bool) -> void:
	if paused:
		prevhidden = visible
		hide()
	else:
		visible = prevhidden
