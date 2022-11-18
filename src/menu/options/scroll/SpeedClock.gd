extends Scroll

func _ready():
	cursor = Shared.clock_show
	set_label()

func set_value():
	Shared.clock_show = cursor
	var b = cursor == Shared.SPEED.BOTH
	UI.clock_file.visible = b or Shared.clock_show == Shared.SPEED.FILE
	UI.clock_map.visible = b or Shared.clock_show == Shared.SPEED.MAP
	
	MenuOptions.fill_items()
