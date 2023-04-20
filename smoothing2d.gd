extends Node2D
class_name Smoothing2D

export var target : NodePath

var target_node : Node2D

var old_position : Vector2
var current_position : Vector2

func _ready():
	target_node = get_node(target)
	current_position = target_node.global_position
	old_position = target_node.global_position

func _physics_process(_delta):
	old_position = current_position
	current_position = target_node.global_position

func _process(_delta):
	var f = Engine.get_physics_interpolation_fraction()
	self.global_position = old_position.linear_interpolate(current_position,f)
