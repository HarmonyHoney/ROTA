extends MenuBase

onready var file_open := $FileOpen
onready var lists := $Lists
onready var list_back := $Lists/ListBack.get_children()

var offset_y := 0.0
onready var offset_dist : float = items[1].rect_position.y - items[0].rect_position.y

func _physics_process(delta):
	for i in items.size():
		items[i].modulate.a = 1.0 if i == cursor else 1.0 - sub_ease.smooth()
		list_back[i].modulate.a = items[i].modulate.a
	lists.rect_position.y = sub_ease.smooth() * offset_y

func accept():
	offset_y = (cursor - 1) * -offset_dist
	if items[cursor].is_new:
		Shared.load_slot(cursor)
		is_open = false
	else:
		sub_menu(file_open)
