extends AudioStreamPlayer

export (Array, AudioStream) var ost = []

var last_song := -1
var array = []

export var wait_range := Vector2(10, 90)
var wait_clock := 0.0
var wait_time := 10.0

func _ready():
	connect("finished", self, "finished")
	randomize()
	wait_clock = 4.0

func _physics_process(delta):
	if wait_clock > 0:
		wait_clock -= delta
		if wait_clock <= 0:
			play_song()

func finished():
	wait_clock = rand_range(wait_range.x, wait_range.y)

func play_song():
	if array.empty():
		array = range(ost.size())
		array.erase(last_song)
		array.shuffle()
	
	stream = ost[array[0]]
	last_song = array[0]
	array.remove(0)
	play()
