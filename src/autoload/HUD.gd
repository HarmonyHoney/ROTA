extends CanvasLayer

var kids = {}

func _ready():
	for i in get_children():
		kids[i.name.to_lower()] = i
	
	show()

func show(arg := "none"):
	for i in kids.values():
		i.visible = false
	
	if kids.has(arg.to_lower()):
		kids[arg.to_lower()].visible = true
