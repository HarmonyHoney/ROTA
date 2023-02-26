extends CanvasLayer

onready var gem_label : Label = $Control/Top/Label
onready var clock_label := $Control/Down/Label

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
	up.move(delta, up.show or p)
	down.move(delta, Shared.clock_rank > 0 and (down.show or p))
	keys.move(delta)
	
	clock_down.modulate.a = clock_ease.count(delta)

func scene_changed():
	up.clock = 0.0
	var m = Shared.map_name != ""
	var b = Shared.clock_show == Shared.SPEED.BOTH
	clock_file.visible = m and (b or Shared.clock_show == Shared.SPEED.FILE)
	clock_map.visible = not "hub" in Shared.map_name and m and (b or Shared.clock_show == Shared.SPEED.MAP)
	clock_ease.show = false

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
	
