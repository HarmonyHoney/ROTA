@tool
extends Control

@export var action := ""
@export var text := "Label": set = set_text

func _ready():
	$Label.text = text

func set_text(arg):
	text = arg
	$Label.text = text
