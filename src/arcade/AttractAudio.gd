extends AudioStreamPlayer2D

export(Array, AudioStream) var list : Array = []

export var wait := Vector2(0.1, 0.3)
var clock = 0.0

func _ready():
	randomize()

func _process(delta):
	if !playing: clock -= delta
	
	if clock < 0:
		clock = rand_range(wait.x, wait.y)
		stream = list[randi() % list.size()]
		play()

