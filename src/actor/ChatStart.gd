extends Node2D

export var arrow_path : NodePath
onready var arrow := get_node_or_null(arrow_path)

export (Array, String, MULTILINE) var lines := ["Lovely day!", "I do adore the flowers", "Hello (="]
export (String, MULTILINE) var queue_write := "" setget set_queue_write

var line := -1
var queue := []

func _ready():
	if arrow:
		arrow.connect("open", self, "open")

func set_queue_write(arg := queue_write):
	queue_write = arg
	queue = queue_write.split_floats(",", false)

func open():
	Audio.play("menu_joy", 0.5, 0.8)

	if queue.size() == 0:
		queue = range(lines.size())
		queue.shuffle()
		queue.erase(line)
	
	line = posmod(int(queue.pop_front()), lines.size())
	Shared.chat.open(lines[line], arrow, global_transform)

