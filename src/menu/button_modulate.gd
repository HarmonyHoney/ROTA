extends Node

@export var button_path : NodePath = "."
@onready var button : TouchScreenButton = get_node_or_null(button_path)

@export var color_path : NodePath = "."
@onready var color_node : CanvasItem = get_node_or_null(color_path)

@export var press_color := Color(1,0,1, 1.0)
@export var idle_color := Color(1,1,1, 0.5)

func _ready():
	if is_instance_valid(button):
		button.connect("pressed", Callable(self, "interact"))
		button.connect("released", Callable(self, "interact"))
	
	if is_instance_valid(color_node):
		color_node.modulate = idle_color

func interact():
	if is_instance_valid(button) and is_instance_valid(color_node):
		color_node.modulate = press_color if button.is_pressed() else idle_color
