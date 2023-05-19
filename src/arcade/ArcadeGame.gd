extends Node2D

onready var cam := $Camera2D
onready var map_node := $Map
onready var center_node := $UI/Control/Center
onready var label_node := $UI/Control/Center/Label
onready var wipe_mat : ShaderMaterial = $UI/Control/Wipe.material


export var tile_size := 12.0

export(String, DIR) var folder := ""
onready var maps : Array = Shared.list_all_files(folder)
export var map := 0 setget set_map
var map_ease := EaseMover.new(1.0, 0.01)

var candies := []

export var room_size := 600.0

export var wrap_cam = 0
export var cam_speed := 100.0
var wrap_angle = 0.0
var delta_scale := 1.0

var btn_a := false
var btn_b := false
var is_unpause := false

var candy_scene := load("res://src/arcade/Candy.tscn")

onready var music : AudioStreamPlayer = Audio.dict["music_arcade"]

func _ready():
	MenuPause.connect("opened", self, "pause")
	scene()
	Audio.play("arcade_boot")
	yield(get_tree().create_timer(1.0), "timeout")
	music.play()

func _exit_tree():
	if music:
		music.stop()

func _physics_process(delta):
	var m = MenuPause.is_paused
	var a = Input.is_action_pressed("jump")
	var b = Input.is_action_pressed("grab")
	
	if is_unpause: is_unpause = a or b
	if !is_unpause:
		btn_a = a and !m
		btn_b = b and !m
	
	var s = map_ease.count(delta)
	var f = map_ease.frac()
	
	if !map_ease.is_last:
		cam.zoom = Vector2.ONE * lerp(1.1, 3.0, s)
		cam.position = map_ease.from_lerp_to(s)
		center_node.rect_scale = Vector2.ONE * lerp(0.0, 2.5, s)
		wipe_mat.set_shader_param("radius", lerp(0.71, 0.0, ease(1.0 - f, 0.17)))
		
		if map_ease.is_complete:
			yield(get_tree(), "physics_frame")
			scene()
	
	if wrap_cam > 0:
		cam.position += Vector2.RIGHT.rotated(wrap_angle) * cam_speed * delta
		cam.position = Vector2(wrapf(cam.position.x, -room_size, room_size), wrapf(cam.position.y, -room_size, room_size))
		
		map_ease.from = cam.position
	
	
	if map == 0 and (btn_a or btn_b) and !m and map_ease.clock == 0.0:
		win(true)

func set_map(arg := map):
	map = max(0, arg)
	#print("map: ", map)
	if maps and label_node:
		var loop = floor(map / maps.size())
	
		label_node.text = (str(loop + 1) + "-" if loop > 0 else "") + str(map % maps.size())

func wrap_tiles(_map):
	var tiles = _map.get_used_cells()
	
	for t in tiles:
		for x in [-1, 0, 1]:
			for y in [-1, 0, 1]:
				if !(x == 0 and y == 0) :
					var vec = t + (Vector2(x, y) * tile_size)
					_map.set_cell(vec.x, vec.y, 0)

func win(arg := false):
	if candies.size() > 0 and !arg: return
	
	map_ease.show = true
	self.map += 1
	
	Audio.play("arcade_win", 0.7, 1.1)

func lose():
	map_ease.show = true
	self.map -= 1
	
	Audio.play("arcade_lose", 0.7, 1.1)

func scene():
	wrap_cam = floor(map / maps.size())
	var c = clamp(wrap_cam - 1, 1.0, 5.0)
	cam_speed = c * 100
	delta_scale = 1.0 + (clamp(wrap_cam - 1, 0.0, 5.0) * 0.2)
	
	#print("wrap_cam: ", wrap_cam, " cam_speed: ", cam_speed, " delta_scale : ", delta_scale)
	
	randomize()
	wrap_angle = lerp(0.0, TAU, (randi() % 3) / 4.0) + (0.0 if wrap_cam < 2 else deg2rad(45.0))
	#print(rad2deg(wrap_angle))
	
	map_ease.from = Vector2.ZERO
	map_ease.show = false
	
	cam.position = Vector2.ZERO
	cam.zoom = Vector2.ONE * 1.1
	for i in map_node.get_children():
		i.queue_free()
	
	var m = load(maps[map % maps.size()]).instance()
	map_node.add_child(m)
	
	for i in m.get_children():
		if i.is_in_group("solid_map"):
			wrap_tiles(i)
		if i.is_in_group("back"):
			i.visible = false
	
	yield(get_tree(), "idle_frame")
	
	if wrap_cam > 2:
		var g = get_tree().get_nodes_in_group("candy")
		for i in g:
			var d = candy_scene.instance()
			d.position = i.position
			i.get_parent().add_child(d)
			d.dir_x = -i.dir_x

func pause(arg := false):
	is_unpause = !arg
