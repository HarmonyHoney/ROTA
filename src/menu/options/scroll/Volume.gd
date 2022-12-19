extends Scroll

export var bus := 0
onready var audio := $Audio

func _ready():
	count = 10
	audio.bus = AudioServer.get_bus_name(bus)
	cursor = Shared.volume[bus] / 10
	set_label()

func set_value():
	Shared.set_volume(bus, cursor * 10)
	audio.pitch_scale = rand_range(0.5, 1.5)
	audio.play()
