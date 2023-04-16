extends CanvasLayer

onready var gem_label : Label = $Control/Top/Labels/Control/Center/Label
onready var clock_label : Label = $Control/Down/Labels/Control/Center/Label
onready var color_rect := $Control/ColorRect

var gem_easy = EaseMover.new()
onready var gem_centers = $Control/Top/Labels/Control.get_children()
onready var gem_labels = [$Control/Top/Labels/Control/Center/Label, $Control/Top/Labels/Control/Center2/Label]
onready var gem_labels_node := $Control/Top/Labels

var rank_easy = EaseMover.new()
onready var rank_centers  = $Control/Down/Labels/Control.get_children()
onready var rank_labels = [$Control/Down/Labels/Control/Center/Label, $Control/Down/Labels/Control/Center2/Label]
onready var rank_labels_node := $Control/Down/Labels

var up = EaseMover.new()
var down = EaseMover.new()
var keys = EaseMover.new()

onready var clock := $Control/Clock
onready var clock_file := $Control/Clock/File
onready var clock_map := $Control/Clock/Map
onready var clock_down := $Control/Clock/Down
onready var clock_best := $Control/Clock/Down/Best
onready var clock_goal := $Control/Clock/Down/Goal
onready var clock_ease := EaseMover.new()

func _ready():
	Shared.connect("scene_changed", self, "scene_changed")
	
	gem_label.text = str(Shared.gem_count)
	
	up.node = $Control/Top
	up.to = up.node.rect_position
	up.from = up.to - Vector2(0, 120)
	up.show = false
	
	down.node = $Control/Down
	down.to = down.node.rect_position
	down.from = down.to + Vector2(0, 120)
	down.show = false
	
	keys.node = $Control/Keys
	keys.to = keys.node.rect_position
	keys.from = keys.to + Vector2(0, 80)
	keys.show = false
	
	scene_changed()
	clock.modulate.a = Shared.clock_alpha

func _physics_process(delta):
	var p = MenuPause.is_open
	up.move(delta, up.show or (p and Shared.gem_count > 0))
	down.move(delta, down.show or (p and Shared.clock_rank > 0))
	keys.move(delta)
	
	if !gem_easy.is_complete:
		gem_count(delta, gem_easy, gem_centers, gem_labels_node)
	
	if !rank_easy.is_complete:
		gem_count(delta, rank_easy, rank_centers, rank_labels_node, 1.0)
	
	clock_down.modulate.a = clock_ease.count(delta, clock_ease.show and !(MenuPause.is_paused and !MenuPause.is_open))

func scene_changed(override := false):
	up.clock = 0.0
	var m = Shared.map_name != "" or override
	var h = "hub" in Shared.map_name
	var b = Shared.clock_show == Shared.SPEED.BOTH
	var t = Shared.clock_show == Shared.SPEED.TRADE
	clock_file.visible = m and ((t and h) or (b or Shared.clock_show == Shared.SPEED.FILE))
	clock_map.visible = m and !h and (t or b or Shared.clock_show == Shared.SPEED.MAP)
	clock_ease.show = m and !h and Shared.clock_show > 0

func menu_keys(accept := "", cancel := ""):
	var c = $Control/Keys/List.get_children()
	
	# accept
	var is_a = accept != ""
	c[0].visible = is_a # label
	c[0].text = accept
	c[1].visible = is_a # key
	
	# cancel
	var is_c = cancel != ""
	c[2].visible = is_c # spacer
	c[3].visible = is_c # label
	c[3].text = cancel
	c[4].visible = is_c # key
	

func gem_text(arg := 0, is_animate := true, _easy := gem_easy, _labels := gem_labels, _labels_node := gem_labels_node):
	_easy.clock = 0.0 if is_animate else (_easy.time * 0.99)
	_easy.from.x = _labels_node.rect_min_size.x
	_easy.to.x = str(arg).length() * 62
	
	yield(get_tree(), "idle_frame")
	
	for i in 2:
		var a = arg - i
		var s = str(a) if a > 0 else ""
		_labels[1 - i].text = s

func rank_text(arg := 0, is_animate := true):
	gem_text(arg, is_animate, rank_easy, rank_labels, rank_labels_node)

func gem_count(delta, _easy, _centers, _labels_node, _scale = -1):
	var s = _easy.count(delta)
	_labels_node.rect_min_size = _easy.from_lerp_to(s)
	
	var vec = [Vector2.ZERO, Vector2(0, 120 * _scale)]
	var scl = [Vector2.ONE, Vector2.ONE * 0.33]
	for i in 2:
		var gc = _centers[i]
		gc.rect_scale = scl[i].linear_interpolate(scl[1 - i], s)
		gc.rect_position = vec[i].linear_interpolate(vec[1 - i], s)
