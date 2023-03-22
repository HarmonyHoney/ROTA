extends VisibilityNotifier2D

export var node_path : NodePath = "."
onready var show_node := get_node_or_null(node_path)

func _enter_tree():
	connect("screen_entered", self, "enter")
	connect("screen_exited", self, "exit")

func enter():
	if show_node: show_node.visible = true

func exit():
	if show_node: show_node.visible = false
