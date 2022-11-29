extends MenuBase

onready var panel := $Center/Panel

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func accept():
	if items[cursor].is_in_group("bye"):
		back()
	else:
		audio_accept()
		UI.emit_signal("dialog_accept")

func back():
	audio_back()
	UI.emit_signal("dialog_bye")
	self.is_open = false

func open():
	UI.keys.show = true

func close():
	UI.keys.show = false
	UI.emit_signal("dialog_close")

func write(arg := []):
	var c = items_node.get_children()

	for i in c.size():
		c[i].visible = i < arg.size() or i == c.size() - 1
		if i < arg.size():
			c[i].text = str(arg[i])
	
	fill_items()
	
	panel.rect_min_size = items_node.rect_size + Vector2(100, 50)
	
