extends AudioStreamPlayer

export (Array, AudioStream) var ost = []

var last_song := -1
var array = []

func _ready():
	randomize()
	play_song()

func _on_Music_finished():
	play_song()

func play_song():
	if array.empty():
		array = range(ost.size())
		array.erase(last_song)
		array.shuffle()
	
	stream = ost[array[0]]
	last_song = array[0]
	array.remove(0)
	play()
