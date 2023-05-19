extends Node

export var is_refresh := false setget set_refresh

var dict = {}

onready var music_player := $Music/Music
export (Array, AudioStream) var ost = []
var last_song := -1
var music_que = []

export var wait_range := Vector2(10, 90)
var wait_clock := 0.0
var wait_time := 10.0
var music_ease := EaseMover.new(1.0, -1)

func _ready():
	music_player.connect("finished", self, "music_finished")
	set_refresh()
	
	randomize()
	wait_clock = 4.0

func play(arg = "menu_cursor", from := 1.0, to := -1.0, pos := 0.0):
	if arg is String and dict.has(arg):
		arg = dict[arg]
	
	if is_instance_valid(arg) and (arg is AudioStreamPlayer or arg is AudioStreamPlayer2D):
		arg.pitch_scale = from if to < 0 else rand_range(from, to)
		arg.play(pos)

func _physics_process(delta):
	if wait_clock > 0:
		wait_clock -= delta
		if wait_clock <= 0:
			music_play()
	
	var s = music_ease.count(delta, !Shared.is_arcade)
	if !music_ease.is_last:
		var m = dict["music_music"]
		m.volume_db = lerp(-30.0, 0.0, s)
		
		if music_ease.clock == 0.0:
			m.stop()
		elif music_ease.last == 0.0 and !m.playing:
			m.play(m.get_playback_position())

func music_finished():
	if !Shared.is_arcade:
		wait_clock = rand_range(wait_range.x, wait_range.y)
		print("music_finished, wait_clock: ", wait_clock)

func music_play():
	if music_que.empty():
		music_que = range(ost.size())
		music_que.erase(last_song)
		music_que.shuffle()
	
	last_song = music_que.pop_front()
	music_player.stream = ost[last_song]
	music_player.play()

func set_refresh(arg := false):
	is_refresh = arg
	dict = {}
	for i in Shared.get_all_children(self):
		if i is AudioStreamPlayer or i is AudioStreamPlayer2D:
			dict[str(get_path_to(i)).to_lower().replace("/", "_")] = i
	
	print("Audio.dict refresh: ", dict.keys())
