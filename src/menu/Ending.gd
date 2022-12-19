extends CanvasLayer

onready var label := $Label
onready var label_ease := EaseMover.new(1.5)
var is_start := false
var is_back := false

var clock := 0.0
var time := 2.5

func _ready():
	label.modulate.a = 0.0

func _physics_process(delta):
	if !is_start:
		label_ease.count(delta, true)
		if label_ease.is_complete:
			is_start = true
			label_ease.clock = 0.0
	elif !is_back:
		label.modulate.a = label_ease.count(delta, true)
		if label_ease.is_complete:
			is_back = true
	elif clock < time:
		clock += delta
	else:
		label.modulate.a = label_ease.count(delta, false)
		if label_ease.clock == 0:
			Shared.wipe_scene(Shared.title_path)
			set_physics_process(false)
