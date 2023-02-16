extends Scroll

export (String, "hair", "skin", "fit", "eye") var part := "hair"

onready var swatch := $HBoxContainer.get_children()

func _ready():
	count = Shared.player.palette.size() - 1

func set_value():
	var p = []
	var pal = Shared.player.palette
	for i in [-2, -1, 0, 1, 2]:
		p.append(pal[posmod(cursor + i, pal.size())])
	
	for i in p.size():
		swatch[i].modulate = p[i]
	
	if label_value: label_value.modulate = p[1]
	
	if Shared.player.dye[part] != cursor:
		Shared.player.dye[part] = cursor
