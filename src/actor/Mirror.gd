extends Node2D

onready var arrow := $Arrow
export var dir := 0
export var door_path : NodePath
onready var door_node := get_node_or_null(door_path)
onready var p = Shared.player
onready var back_rect : Rect2 = $Back.get_rect()
onready var rig := $Back/Center/Rig
onready var rig_ease := EaseMover.new()
onready var stage := $Stage
onready var sky_mat : ShaderMaterial = $Back.material
onready var sky_pal : Array = Clouds.sky_pal.duplicate()

var from := []
var to := []
onready var lights := get_tree().get_nodes_in_group("light")

var dist := Vector2.ZERO
export var offset := Vector2(100, 0)
var dir_x := 1.0
export var hide_distance := 50.0

func _ready():
	MenuMakeover.connect("opened", self, "closed")
	
	arrow.dir = posmod(dir, 4)
	rig.global_rotation = 0
	rig_ease.clock = rig_ease.time
	
	yield(get_tree().create_timer(3.0), "timeout")
	
	create_rig()

func _process(delta):
	var s = rig_ease.count(delta)
	var x_scale := get_viewport_rect().size.x / 1280
	var c_dist := abs(to_local(Cam.global_position).x / 75.0)
	
	rig.modulate.a = s
	stage.modulate.a = 1.0 - s
	stage.scale = Vector2.ONE * lerp((3.42 * x_scale) + c_dist, 1.0, s)
	
	for i in lights:
		i.self_modulate.a = s
	
	# sky palette
	var sps = sky_pal.size()
	var sky_step = posmod(Clouds.sky_step + (sps / 2.0) , sps)
	var sf = Clouds.step_frac
	
	for i in 2:
		sky_mat.set_shader_param("col" + str(i + 1), sky_pal[sky_step - 2 - i].linear_interpolate(sky_pal[sky_step - 1 - i], sf))
	
	# animate
	for i in from.size():
		if is_instance_valid(to[i]) and is_instance_valid(from[i]):
			to[i].transform = from[i].transform
	
	dist = to_local(p.global_position)
	rig.position = dist + (offset * dir_x)
	rig.visible = back_rect.grow(hide_distance).has_point(rig.position)
	
	if abs(dist.x) > 200:
		dir_x = -sign(dist.x)

func create_rig():
	for i in rig.get_children():
		i.queue_free()
	
	var s = p.sprites.duplicate(DUPLICATE_USE_INSTANCING)
	s.get_node("SpriteArea").queue_free()
	s.modulate.a = 1
	rig.add_child(s)
	
	from = []
	to = []
	var list = [p.sprites, p.spr_root, p.spr_body, p.spr_hand_l, p.spr_hand_r, p.spr_eyes]
	
	for i in Shared.get_all_children(p.hair_front):
		if i.is_in_group("mirror"):
			print("mirror: ", i)
			list.append(i)
	
	for i in list:
		var path = p.sprites.get_path_to(i)
		if s.has_node(path):
			from.append(i)
			to.append(s.get_node(path))
	
	for n in ["Back", "Front"]:
		for i in Shared.get_all_children(s.get_node("Root/Body/Hair" + n)):
			for c in ["scale_x", "turn_angle"]:
				if i.has_method(c) and !p.is_connected(c, i, c):
					p.connect(c, i, c)

func _on_Arrow_open():
	MenuMakeover.is_open = true
	arrow.is_locked = true
	rig_ease.show = false

func closed(arg := false):
	if arg: return
	
	arrow.is_locked = false
	rig_ease.show = true
	create_rig()
	
	if is_instance_valid(Shared.door_in):
		Shared.door_in.modulate.a = 1.0
		Shared.door_in.arrow.is_locked = false
	
