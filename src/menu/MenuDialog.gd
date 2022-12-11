extends MenuBase

onready var panel := $Center/Panel

func accept():
	if items[cursor].is_in_group("bye"):
		self.is_open = false
	else:
		UI.emit_signal("dialog_accept")
		match items[cursor].text:
			"Makeover":
				sub_menu(MenuMakeover)

func close():
	UI.emit_signal("dialog_closed")

func write(arg := []):
	var c = items_node.get_children()

	for i in c.size():
		c[i].visible = i < arg.size() or i == c.size() - 1
		if i < arg.size():
			c[i].text = str(arg[i])
	
	fill_items()
	
	panel.rect_min_size = items_node.rect_size + Vector2(100, 50)
