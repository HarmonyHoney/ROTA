extends CanvasLayer

var controls = {}

onready var gem_label : Label= $Control/Gems/Label

func _ready():
	for i in $GameControls.get_children():
		controls[i.name.to_lower()] = i
	show()
	
	gem_label.text = str(Shared.gem_count)

func show(arg := "none"):
	for i in controls.values():
		i.visible = false
	
	if controls.has(arg.to_lower()):
		controls[arg.to_lower()].visible = true
