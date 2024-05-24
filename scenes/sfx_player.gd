extends Node3D

var children:Dictionary

func _ready() -> void:
	for i in get_children():
		if i is AudioStreamPlayer3D:
			children[i.name] = i

func play_sound(_name:String) -> void:
	var stream = children[_name]
	if stream == null:
		push_warning(_name," isn't a valid child, not playing sound.")
		return
	if stream.get_meta("StopOtherSounds") == true:
		stop_all_sounds()
	stream.play()

func get_sound(_name:String) -> AudioStreamPlayer3D:
	return children[_name]

func set_sound_speed(_name:String,playback:float) -> void:
	var stream = children[_name]
	if stream == null:
		push_warning(_name," isn't a valid child, not setting speed.")
		return
	stream.pitch_scale = playback
	
func stop_sound(_name:String) -> void:
	var stream = children[_name]
	if stream == null:
		push_warning(_name," isn't a valid child, not stoping sound.")
		return
	children[_name].stop()
	
func stop_all_sounds() -> void:
	for i in children:
		children[i].stop()
