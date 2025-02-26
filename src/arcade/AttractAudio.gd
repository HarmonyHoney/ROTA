extends AudioStreamPlayer2D

@export var list : Array = [] # (Array, AudioStream)

@export var wait := Vector2(0.1, 0.3)
var clock = 0.0

func _ready():
	randomize()

func _process(delta):
	if !playing: clock -= delta
	
	if clock < 0:
		clock = randf_range(wait.x, wait.y)
		stream = list[randi() % list.size()]
		play()

