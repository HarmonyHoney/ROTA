extends Node

var actions := []
var history := []

var codes := {"konami code": "up, up, down, down, left, right, left, right, push, jump",
	"big hair": "up, right, down, left, up, right, down, left, up, left, down, right, up, left, down, right",
	"moon jump": "up, up, up, up, up, up, up, down, up, up, up, up, up, up, up, down"}

signal activate(cheat)

func _ready():
	for i in InputMap.get_actions():
		if !i.begins_with("ui_"):
			actions.append(i)
	clear_history()

func _input(event):
	if event.is_pressed() and !event.is_echo():
		for i in actions:
			if event.is_action_pressed(i):
				add(i)

func clear_history():
	history.clear()
	for i in 20:
		history.append("")

func add(arg):
	history.append(arg)
	history.remove(0)
	#print(history)
	
	for i in codes.keys():
		if codes[i] in str(history):
			print("Cheat Code Activated: ", i)
			emit_signal("activate", i)
			clear_history()

