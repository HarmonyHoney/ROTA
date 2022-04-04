extends CanvasLayer

onready var control := $Control

var visible := true setget set_visible

func _ready():
	self.visible = false

func set_visible(arg := true):
	visible = arg
	control.visible = visible
