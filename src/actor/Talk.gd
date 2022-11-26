extends Node2D

onready var arrow := $Arrow

onready var audio := $Audio

var queue := []
export(Array, AudioStream) var clips := []
export(Array, String, MULTILINE) var text := []

func _on_Arrow_open():
	arrow.is_locked = true
	
	if queue.size() == 0:
		queue = range(clips.size())
		randomize()
		queue.shuffle()
		print(queue)
	
	var q = queue.pop_back()
	
	audio.stream = clips[q]
	audio.play()
	
	UI.caption_label.text = text[q]
	UI.caption.show = true
	
	yield(get_tree().create_timer(2.0), "timeout")
	arrow.is_locked = false
	UI.caption.show = false
