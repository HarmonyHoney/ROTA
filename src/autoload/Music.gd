extends AudioStreamPlayer

export var ost1 : AudioStream
export var ost2: AudioStream
export var ost3 : AudioStream
export var ost4 : AudioStream

var last_song := -1
var array = []

func _ready():
	randomize()
	play_song()

func _on_Music_finished():
	play_song()

func play_song():
	if array.size() == 0:
		array = [0,1,2,3]
		array.erase(last_song)
		array.shuffle()
	
	match array[0]:
		0:
			stream = ost1
		1:
			stream = ost2
		2:
			stream = ost3
		3:
			stream = ost4
	
	last_song = array[0]
	array.remove(0)
	play()
