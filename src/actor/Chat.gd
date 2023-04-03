tool
extends Node2D

onready var bubble := $Bubble
onready var label_back := $Bubble/Center/Back
onready var label := $Bubble/Center/Label
onready var rect := $Bubble/Rect
onready var triangle := $Bubble/Triangle
onready var shadows := $Bubble/Shadow.get_children()

export (String, MULTILINE) var dialog := "I do adore the flowers" setget set_dialog
export var is_editor := false
export var is_show := false setget set_is_show
export var panel_grow := Vector2(20, 17)
export var show_range := Vector2(-10, -45)
var panel_min := Vector2(35, 55)

var cursor := 0
var read_clock := 0.0
var read_time := 2.0
var last_s := -1.0

var easy := EaseMover.new(0.05)
var show_easy := EaseMover.new()
var panel_easy := EaseMover.new(0.3)

var arrow
var key_up := false
var key_hold := false

func _physics_process(delta):
	if Engine.editor_hint and !is_editor: return
	
	var s = show_easy.count(delta, is_show)
	if s != last_s:
		modulate.a = s
		if bubble:
			bubble.position.y = lerp(show_range.x, show_range.y, s)
	last_s = s
	
	if rect and triangle:
		if panel_easy.clock < panel_easy.time:
			rect.size = panel_easy.move(delta, is_show)
			shadows[1].size = rect.size
		triangle.position.y = rect.size.y
		triangle.scale = Vector2.ONE * s
		shadows[0].transform = triangle.transform
	
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
		
		elif (is_instance_valid(arrow) and !arrow.is_active and !Engine.editor_hint) or (key_up and !key_hold):
			is_show = false
		
		elif read_clock < read_time:
			read_clock += delta
			if read_clock >= read_time:
				is_show = false
		
		if !is_show:
			if arrow: arrow.is_locked = false

func set_dialog(arg := dialog):
	dialog = arg
	cursor = 0
	read_clock = 0.0
	easy.clock = 0.0
	if label and label_back and rect:
		label.text = dialog
		label.visible_characters = 0
		
		label_back.text = dialog
		label_back.visible_characters = 1
		label_back.modulate.a = 0
		
		panel_easy.clock = 0.0
		panel_easy.from = rect.size
		panel_easy.to = (label.get_font("font").get_string_size(dialog) / 2.0) + panel_grow
		panel_easy.to.x = max(panel_easy.to.x, panel_min.y)

func set_is_show(arg := is_show):
	is_show = arg
	if is_show:
		set_dialog()

func open(_dialog := dialog, _arrow := arrow, _gt := global_transform):
	if is_show: return
	is_show = true
	key_hold = true
	arrow = _arrow
	if arrow: arrow.is_locked = true
	if rect: rect.size = Vector2.ONE * panel_min.x
	global_transform = _gt
	self.dialog = _dialog
