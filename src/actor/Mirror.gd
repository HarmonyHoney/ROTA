extends Node2D

onready var arrow := $Arrow

export var dir := 0

export var door_path : NodePath
onready var door_node := get_node_or_null(door_path)

onready var color_rect := $Back/ColorRect
onready var rig := $Rig
onready var rig_ease := EaseMover.new()

var from = []
var to = []

onready var p = Shared.player

var dist := Vector2.ZERO
export var dist_scale := Vector2(0.9, 0.9)
export var offset := Vector2(100, 0)
var dir_x := 1.0

export var hide_distance := 50.0

func _ready():
	MenuMakeover.connect("closed", self, "closed")
	get_tree().connect("idle_frame", self, "idle_frame")
	
	arrow.dir = posmod(dir, 4)
	
	var sm = $Wall/ColorRect.material
	for i in ["col1", "col2"]:
		sm.set_shader_param(i, BG.mat.get_shader_param(i))
	
	for i in 2:
		yield(get_tree(), "idle_frame")
	create_rig()

func _physics_process(delta):
	rig.modulate.a = rig_ease.count(delta)

func create_rig():
	for i in rig.get_children():
		i.queue_free()
	
	var sprites = p.sprites.duplicate()
	rig.add_child(sprites)
	rig.global_rotation = 0
	
	var combo = [[p.sprites, sprites],
	[p.spr_root, sprites.get_node("Root")],
	[p.spr_body, sprites.get_node("Root/Body")],
	[p.spr_hand_l, sprites.get_node("Hands/Left")],
	[p.spr_hand_r, sprites.get_node("Hands/Right")]]
	
	from = []
	to = []
	for i in combo:
		from.append(i[0])
		to.append(i[1])
	
	for i in Shared.get_all_children(sprites.get_node("Root/Body/Hair")):
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
	
