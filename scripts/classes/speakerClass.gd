class_name Speaker
extends Node3D

@export var stopPlayer:bool = false
@export var visibleNotifier:VisibleOnScreenNotifier3D
@export var cameraPlacementNode:Node3D
@export var playerPlacementNode:Node3D
@export var Interactable:interactComp

@export var exportDialog:Array  = [
	"s:Welcome to [color=57C8DB]Sorakai Quest!!!",
	"p:Woah... This is the coolest thing ever created.",
	"s:I know.",
	"s:burger burger burger burger burger burger burger burger burger burger burger burger burger burger burger burger burger",
	"p:[wave]ohio"
]
var dialog:Array[Array] = []

func _ready() -> void:
	if exportDialog[0] is Array:
		return
		
	for i:int in range(0,exportDialog.size()):
		var s:String = exportDialog[i]
		dialog.append([])
		#THIS SUCKS BUT WHATEVER
		if s.begins_with("s:"):
			dialog[i].append(self)
		else:
			dialog[i].append("player")
			
		dialog[i].append(s.substr(2))

func getDialog() -> Array:
	if dialog.size() == 0:
		return []
	if exportDialog[0] is Array:
		#return exportDialog.pick_random()
		pass
	return dialog

func on_interact() -> void:
	GameManager.CurrentState.play_dialog(self)
