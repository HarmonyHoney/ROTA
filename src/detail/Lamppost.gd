tool
extends Node2D

onready var circle := $Circle

var t := 0.0

func _physics_process(delta):
	#if Engine.editor_hint: return
	
	t += delta
	
	if circle:
		var s = 1.0 + (sin(t * 1.5) * 0.1)
		circle.scale = Vector2.ONE * s

