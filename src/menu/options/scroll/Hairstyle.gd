extends Scroll

export(String, "back", "front") var order = "back"

export(Array, String, FILE) var scenes := []

onready var hbox := $HBoxContainer
onready var circle := $HBoxContainer/Circle
var items := []
var styles := []

func _ready():
	label_desc.text = "Hair" if order == "front" else ""
	for i in scenes.size():
		if i == 0: continue
		
		var c = circle.duplicate()
		hbox.add_child(c)
		
		var s = load(scenes[i]).instance()
		
		if order == "back":
			s.show_behind_parent = true
		
		s.position = Vector2(35, 35)
		c.add_child(s)
	
	items = hbox.get_children()
	
	for i in items.size():
		items[i].visible = i < 5
	
	# specific mohawk fix
	for i in Shared.get_all_children(hbox):
		if i.get("z_index") and i.z_index == -2:
			i.z_index = 0

func set_value():
	Shared.player.set("hairstyle_" + order, cursor)
	
	for i in items:
		i.visible = false
	
	for i in 5:
		var p = posmod(cursor + (i - 2), items.size())
		hbox.move_child(items[p], i)
		items[p].visible = true
