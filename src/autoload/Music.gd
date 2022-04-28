extends AudioStreamPlayer

export var ost1 : AudioStream
export var ost2: AudioStream

func _ready():
	stream = ost2
	play()


func _on_Music_finished():
	stream = ost2 if stream == ost1 else ost1
	
	play()
