extends Node2D

onready var arrow := $Arrow
export var dir := 0
export var door_path : NodePath
onready var door_node := get_node_or_null(door_path)
onready var color_rect := $Back/ColorRect
onready var rig := $Rig
onready var rig_ease := EaseMover.new()
onready var p = Shared.player

var from = []
var to = []

var dist := Vector2.ZERO
export var offset := Vector2(100, 0)
var dir_x := 1.0
export var hide_distance := 50.0

func _ready():
	MenuMakeover.connect("closed", self, "closed")
	get_tree().connect("idle_frame", self, "idle_frame")
	
	arrow.dir = posmod(dir, 4)
	rig.global_rotation = 0
	create_rig()
	
	var sm = $Wall/ColorRect.material
	for i in ["col1", "col2"]:
		sm.set_shader_param(i, BG.mat.get_shader_param(i))

func _physics_process(delta):
	rig.modulate.a = rig_ease.count(delta)

func create_rig():
	for i in rig.get_children():
		i.queue_free()
	
	var s = p.sprites.duplicate()
	s.modulate.a = 1
	rig.add_child(s)
	
	from = []
	to = []
	var list = [p.sprites, p.spr_root, p.spr_body, p.spr_hand_l, p.spr_hand_r]
	for i in list:
		var path = p.get_path_to(i)
		if rig.has_node(path):
			from.append(i)
			to.append(rig.get_node(path))
	
	for i in Shared.get_all_children(s.get_node("Root/Body/Hair")):
		if i.has_method("scale_x"):
			p.connect("scale_x", i, "scale_x")

func _on_Arrow_open():
	MenuMakeover.is_open = true
	arrow.is_locked = true
	rig_ease.show = false

func closed():
	arrow.is_locked = false
	rig_ease.show = true
	create_rig()
	
	if is_instance_valid(Shared.door_in):
		Shared.door_in.visible = true
		Shared.door_in.arrow.is_locked = false

func idle_frame():
	# animate
	for i in from.size():
		to[i].transform = from[i].transform
	
	dist = to_local(p.global_position)
	rig.position = dist + (offset * dir_x)
	rig.visible = color_rect.get_rect().grow(hide_distance).has_point(rig.position)
	
	if abs(dist.x) > 200:
		dir_x = -sign(dist.x)
	
