extends Control

onready var control := $Control
onready var list := control.get_children()
onready var audio := $Audio

var volume := 5

export var bus := 0

func _ready():
	volume = Shared.volume[bus] / 10
	show()

func show():
	for i in list.size():
		list[i].color = Color.green if i + 1 <= volume else Color.red

func axis_x(arg := 1):
	volume = clamp(volume + arg, 0, 10)
	Shared.set_volume(bus, volume * 10)
	show()
	
	audio.pitch_scale = rand_range(0.5, 1.5)
	audio.play()
