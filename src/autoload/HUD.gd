extends CanvasLayer

onready var game : Control = $Game
onready var title : Control = $Title

func _ready():
	show()

func show(arg := "none"):
	game.visible = false
	title.visible = false
	
	var c = get(arg)
	if c != null:
		c.visible = true
