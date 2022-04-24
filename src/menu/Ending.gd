extends CanvasLayer

onready var label := $Label
onready var label_ease := EaseMover.new(null, 1.5)
var is_start := false

func _ready():
	label.modulate.a = 0.0

func _physics_process(delta):
	if !is_start:
		label_ease.count(delta, true)
		if label_ease.is_complete:
			is_start = true
			label_ease.clock = 0.0
	elif label_ease.clock < label_ease.time:
		label.modulate.a = label_ease.count(delta, true)
