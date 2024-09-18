extends Node3D

var children:Dictionary

func _ready() -> void:
	for i in get_children():
		if i is AudioStreamPlayer3D:
			children[i.name] = i
			
func play_sound_into(_name:String,next_name:String) -> void:
	var stream:AudioStreamPlayer3D = children[_name]
	if stream == null:
		push_warning(_name," isn't a valid child, not playing sound.")
		return
	var stream2:AudioStreamPlayer3D = children[next_name]
	if stream2 == null:
		push_warning(next_name," isn't a valid child, not playing sound.")
		return
	if stream.get_meta("StopOtherSounds") == true:
		stop_all_sounds()
	stream.play()
	await get_tree().create_timer(stream.stream.get_length()).timeout
	if stream.playing:
		stream2.play()
	

func play_sound(_name:String) -> void:
	var stream:AudioStreamPlayer3D = children[_name]
	if stream == null:
		push_warning(_name," isn't a valid child, not playing sound.")
		return
	if stream.get_meta("StopOtherSounds") == true:
		stop_all_sounds()
	stream.play()

func get_sound(_name:String) -> AudioStreamPlayer3D:
	return children[_name]

func set_sound_speed(_name:String,playback:float) -> void:
	var stream:AudioStreamPlayer3D = children[_name]
	if stream == null:
		push_warning(_name," isn't a valid child, not setting speed.")
		return
	stream.pitch_scale = playback
	
func stop_sound(_name:String) -> void:
	var stream:AudioStreamPlayer3D = children[_name]
	if stream == null:
		push_warning(_name," isn't a valid child, not stoping sound.")
		return
	children[_name].stop()
	
func stop_all_sounds() -> void:
	for i:String in children:
		children[i].stop()
