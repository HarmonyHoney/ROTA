extends CanvasLayer

onready var game : Control = $Game
onready var title : Control = $Title
onready var grab1 : Control = $GameGrab1
onready var grab2 : Control = $GameGrab2

func _ready():
	show()

func show(arg := "none"):
	for i in get_children():
		i.visible = false
	
	var c = get(arg)
	if c != null:
		c.visible = true
