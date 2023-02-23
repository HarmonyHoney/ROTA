tool
extends Node2D

onready var label_back := $Center/Back
onready var label := $Center/Label
onready var rect := $Rect
onready var triangle := $Triangle
onready var arrow := $"../Arrow"

export (String, MULTILINE) var dialog := "Lovely Day!" setget set_dialog
export var is_show := true
export var panel_grow := Vector2(20, 17)
export var show_range := Vector2(-110, -150)

var cursor := 0
var read_clock := 0.0
var read_time := 2.0

var easy := EaseMover.new(0.05)
var show_easy := EaseMover.new()
var panel_easy := EaseMover.new(0.3)

func _ready():
	pass

func _physics_process(delta):
	var s = show_easy.count(delta, is_show)
	modulate.a = s
	position.y = lerp(show_range.x, show_range.y, s)
	if rect and triangle:
		if panel_easy.clock < panel_easy.time:
			rect.size = panel_easy.move(delta, is_show)
		triangle.position.y = rect.size.y
		triangle.scale = Vector2.ONE * s
		
	if is_show and s > 0.5:
		if cursor < dialog.length() and label_back and label:
			label_back.modulate.a = easy.count(delta)
			if easy.is_complete:
				if cursor == 0 or dialog[cursor] == " ":
					Audio.play("menu_cancel", 0.75, 1.5)
				
				easy.clock = 0
				cursor += 1
				label.visible_characters = cursor
				label_back.visible_characters = cursor + 1
				label_back.modulate.a = 0
			
		elif arrow and !arrow.is_active:
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
		set_dialog()

func _on_Arrow_activate():
	pass
