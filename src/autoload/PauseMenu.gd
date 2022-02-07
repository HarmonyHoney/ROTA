extends Node2D

var is_paused := false
var cursor := 0
var items = []

onready var menu = $MenuLayer/Menu
onready var cursor_node = $MenuLayer/Menu/Items/Cursor
onready var items_node = $MenuLayer/Menu/Items
onready var sprite = $ImageLayer/Center/Sprite

func _ready():
	for i in [menu, sprite]:
		i.visible = false
	
	items = items_node.get_children()
	items.remove(0)
	
	#Wipe.connect("wipe_in", self, "wipe_in")
	Wipe.connect("wipe_out", self, "wipe_out")
	#Wipe.connect("start_wipe_in", self, "start_wipe_in")
	Wipe.connect("start_wipe_out", self, "start_wipe_out")
	
	CircleZoom.connect("change_pos", self, "change_pos")

func wipe_out():
	if is_paused:
		set_paused(false)
	yield(get_tree().create_timer(0.7), "timeout")
	set_process_input(true)

func start_wipe_out():
	set_process_input(false)

func _input(event):
	var pause = event.is_action_pressed("pause")
	if pause and !Shared.is_level_select:
		press_pause()
		return
	if !is_paused: return
	
	var up = event.is_action_pressed("up")
	var down = event.is_action_pressed("down")
	#var left = event.is_action_pressed("left")
	#var right = event.is_action_pressed("right")
	var enter = event.is_action_pressed("jump")
	var back = event.is_action_pressed("action")
	
	if up or down:
		cursor = clamp(cursor + (-1 if up else 1), 0, items.size() - 1)
	
	if back:
		press_pause()
	elif enter:
		match cursor:
			0:
				press_pause()
			1:
				reset()
			2:
				exit()

func _process(delta):
	var anch = ["left", "top", "right", "bottom"]
	for i in anch:
		var s = "anchor_" + i
		cursor_node.set(s, lerp(cursor_node.get(s), items[cursor].get(s), 0.15))

func press_pause():
	if !is_paused:
		CircleZoom.zoom(CircleZoom.out, 0.2, 0.5, null, Vector2(200, 0))
	else:
		CircleZoom.zoom(0.2, CircleZoom.out, 0.5, null, Vector2.ZERO)
		yield(CircleZoom, "finish")
	set_paused(!is_paused)

func set_paused(pause := true):
	is_paused = pause
	cursor = 0
	
	menu.visible = is_paused
	
	HUD.show("none")
	
	if is_paused:
		sprite.texture = Shared.take_screenshot()
		#sprite.position = Vector2(200, 0)
		sprite.scale = Vector2.ONE * (720 / sprite.texture.get_size().y)
	
	HUD.show("title" if is_paused else "game")
	sprite.visible = is_paused
	get_tree().paused = is_paused
	

func reset():
	CircleZoom.zoom(null, 0, 0.5, null, Vector2(200, 0))
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	get_tree().reload_current_scene()
	
	yield(get_tree(), "idle_frame")
	CircleZoom.zoom(null, 0.6, 1.5, Vector2.ZERO)
	
	set_paused(false)

func exit():
	CircleZoom.zoom(null, Shared.last_orb_radius, 0.5, null, Shared.last_orb_pos)
	yield(CircleZoom, "finish")
	
	get_tree().change_scene(Shared.scene_select)
	Shared.is_level_select = true
	yield(get_tree(), "idle_frame")
	
	CircleZoom.set_pos(Vector2.ZERO)
	CircleZoom.set_radius(CircleZoom.out)
	#CircleZoom.zoom(null, CircleZoom.out, 0)
	
	set_paused(false)

func change_pos(pos):
	sprite.position = pos
	menu.rect_position.x = 50 + pos.x - (CircleZoom.radius * 1280)
