extends Node

onready var expression := Expression.new()
export (String, MULTILINE) var expression_string := "false"

export (String) var erase := ""
export (int, "Off", "On", "Swap", "Push Front", "Push Back") var is_lines := 0
export (Array, String, MULTILINE) var lines := ["Lovely weather!"]
export var is_greeting := false
export var greeting := -1
export var is_queue := false
export (String, MULTILINE) var queue_write := ""

func _ready():
	var error = expression.parse(expression_string, [])
	if error != OK:
		print(expression.get_error_text())
		return
	var result = expression.execute([], Shared)
	if !expression.has_execute_failed() and result:
		var p = get_parent()
		if erase != "":
			var e = erase.split_floats(",", false)
			e.sort()
			e.invert()
			for i in e:
				p.lines.remove(int(i))
		
		if is_lines > 0:
			if is_lines == 1:
				p.lines = lines
			elif is_lines == 2:
				for i in lines.size():
					p.lines[i] = lines[i]
			elif is_lines > 2:
				p.lines = (lines + p.lines) if is_lines == 3 else (p.lines + lines)
		
		if is_greeting:
			p.greeting = greeting
		
		if is_queue:
			p.queue_write = queue_write
	
