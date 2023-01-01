extends Scroll

export (String, "hair", "skin", "fit", "eye") var part := "hair" setget set_part

onready var swatch := $HBoxContainer.get_children()

func _ready():
	set_part()
	count = Shared.player.palette.size() - 1

func set_value():
	var p = []
	var pal = Shared.player.palette
	for i in [-2, -1, 0, 1, 2]:
		p.append(pal[posmod(cursor + i, pal.size())])
	
	for i in p.size():
		swatch[i].modulate = p[i]
	
	if label_value: label_value.modulate = p[1]
	
	Shared.player.dye[part] = cursor

func set_part(arg := part):
	part = arg
	if label_desc: label_desc.text = "" if part == "hair" else part.capitalize()
