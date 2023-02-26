tool
extends Node2D

onready var label_back := $Center/Back
onready var label := $Center/Label
onready var rect := $Rect
onready var triangle := $Triangle
onready var arrow := $"../Arrow"

export (Array, String, MULTILINE) var lines := ["Lovely day!", "I do adore the flowers", "Haven't seen you before (:"]
export (String, MULTILINE) var queue_write := "" setget set_queue_write
var queue := []

export (String, MULTILINE) var dialog := "I do adore the flowers" setget set_dialog

export var is_editor := false
export var is_show := false
export var panel_grow := Vector2(20, 17)
export var show_range := Vector2(-120, -150)

var cursor := 0
var read_clock := 0.0
var read_time := 2.0

var easy := EaseMover.new(0.05)
var show_easy := EaseMover.new()
var panel_easy := EaseMover.new(0.3)

var key_up := false
var key_hold := false

var last := -1.0


func _physics_process(delta):
	if Engine.editor_hint and !is_editor: return
	
	var s = show_easy.count(delta, is_show)
	if s != last:
		modulate.a = s
		position.y = lerp(show_range.x, show_range.y, s)
	last = s
	
	if rect and triangle:
		if panel_easy.clock < panel_easy.time:
			rect.size = panel_easy.move(delta, is_show)
		triangle.position.y = rect.size.y
		triangle.scale = Vector2.ONE * s
	
	# input
	key_up = Input.is_action_pressed("ui_up")
	if key_hold:
		key_hold = key_up
	
	if is_show and s > 0.5:
		if cursor < dialog.length() and label_back and label:
			label_back.modulate.a = easy.count(delta)
			if easy.is_complete:
				easy.clock = 0
				cursor += 1
				label.visible_characters = cursor
				label_back.visible_characters = cursor + 1
				label_back.modulate.a = 0
				
				if !Engine.editor_hint and (cursor - 1 == 0 or dialog[cursor - 1] == " "):
					Audio.play("menu_cancel", 0.75, 1.5)
			
		elif (arrow and !arrow.is_active and !Engine.editor_hint) or (key_up and !key_hold):
			is_show = false
			
		elif read_clock < read_time:
			read_clock += delta
			if read_clock >= read_time:
				is_show = false
		
		if !is_show:
			if arrow: arrow.is_locked = false

func set_queue_write(arg := queue_write):
	queue_write = arg
	queue = queue_write.split_floats(",", false)

func set_dialog(arg := dialog):
	dialog = arg
	cursor = 0
	read_clock = 0.0
	easy.clock = 0.0
	key_hold = true
	if label and label_back and rect:
		label.text = dialog
		label.visible_characters = 0
		
		label_back.text = dialog
		label_back.visible_characters = 1
		label_back.modulate.a = 0
		
		panel_easy.clock = 0.0
		panel_easy.from = rect.size
		panel_easy.to = (label.get_font("font").get_string_size(dialog) / 2.0) + panel_grow

func _on_Arrow_open():
	if !is_show:
		is_show = true
		if arrow: arrow.is_locked = true
		Audio.play("menu_joy", 0.5, 0.8)
		
		if queue.size() == 0:
			queue = range(lines.size())
			queue.shuffle()
		
		if rect: rect.size = Vector2.ONE * 35
		set_dialog(lines[int(queue.pop_front())])

func _on_Arrow_activate():
	pass
