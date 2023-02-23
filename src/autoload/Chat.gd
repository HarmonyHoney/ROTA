tool
extends Node2D

export var is_dialog := true
export (String, MULTILINE) var dialog := "Lovely Day!" setget set_dialog
export var cursor := 0
export var is_show := true

var easy := EaseMover.new(0.05)
var easy_show := EaseMover.new()
var bubble_easy := EaseMover.new(0.3)
var panel_easy := EaseMover.new(0.3)

var read_clock := 0.0
var read_time := 3.0

onready var label_back := $Center/Back
onready var label := $Center/Label
onready var rect := $Rect
onready var triangle := $Triangle
export var panel_grow := Vector2(20, 20)

onready var arrow := $"../Arrow"

func _ready():
	pass

func _physics_process(delta):
	var s = easy_show.count(delta, is_show)
	modulate.a = s
	position.y = lerp(-110, -150, s)
	if rect and triangle:
		triangle.position.y = rect.size.y
		triangle.scale = Vector2.ONE * s
	
	if cursor < dialog.length() and label_back and label:
		label_back.modulate.a = easy.count(delta)
		if easy.is_complete:
			easy.clock = 0
			cursor += 1
			label.visible_characters = cursor
			label_back.visible_characters = cursor + 1
			label_back.modulate.a = 0
			#Audio.play("menu_cursor", 0.8, 1.2)
	elif read_clock < read_time:
		read_clock += delta
		if read_clock >= read_time:
			is_show = false
	
	if panel_easy.clock < panel_easy.time and rect:
		rect.size = panel_easy.move(delta, panel_easy.show and is_show)

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
		
		yield(get_tree(), "idle_frame")
		
		panel_easy.clock = 0.0
		panel_easy.from = rect.size
		panel_easy.to = (Vector2(label.rect_size.x, 35) / 2.0) + panel_grow

func _on_Arrow_open():
	rect.size = Vector2(35, 35)
	set_dialog()
	is_show = true
	Audio.play("menu_joy", 0.8, 1.2)
	arrow.is_active = false

func _on_Arrow_activate():
	panel_easy.to = Vector2(35, 35)
	if !arrow.is_active:
		is_show = false
