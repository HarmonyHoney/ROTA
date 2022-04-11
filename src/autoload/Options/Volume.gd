extends Control

onready var label := $Label2
onready var audio := $Audio

var volume := 5
export var bus := 0

func _ready():
	volume = Shared.volume[bus] / 10
	audio.bus = AudioServer.get_bus_name(bus)
	show()

func axis_x(arg := 1):
	volume = clamp(volume + arg, 0, 10)
	Shared.set_volume(bus, volume * 10)
	show()
	
	audio.pitch_scale = rand_range(0.5, 1.5)
	audio.play()

func show():
	label.text = "< " + str(volume) + " >"
