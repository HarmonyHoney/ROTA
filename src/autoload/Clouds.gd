extends Node2D

onready var bg := $BG
onready var canvas_mod := $CanvasModulate
onready var hide := $Hide
onready var particles := $Hide/Particles2D

onready var center := $Sky/Center
onready var clouds := $Sky/Center/Clouds
onready var clouds1 := $Sky/Center/Clouds1
onready var clouds2 := $Sky/Center/Clouds2
onready var precip := $Precip
onready var audio_rain := $AudioRain

onready var stars := $Sky/Center/Stars
onready var starfield := $Sky/Center/Starfield
onready var star_orbit := $Sky/Center/Stars/Orbit
onready var star_light := $Sky/Center/Stars/Orbit/Light2D
onready var sun := $Sky/Center/Stars/Orbit/Sun
onready var moon := $Sky/Center/Stars/Orbit/Moon

export var cloud_speed := 1.0
var cloud_dir := 1.0
var length = 100.0
var cloud_rotation := 0.0
var star_rotation := 0.0
export var cloud_bonus_rings := 5
export var cloud_front_range = Vector2(500, 1000)
export var orbit_distance := 650.0

export var snow_mat : ParticlesMaterial
export var snow_tex : Texture
export var rain_mat : ParticlesMaterial
export var rain_tex : Texture

var sun_frac := 0.5
var moon_frac := 0.5

export var is_rain := false setget set_is_rain
var is_snow := false
var rain_clock := 60.0
export var rain_range := Vector2(60, 240)
export var dry_range := Vector2(60, 720)
var precip_list = []
var solve_clock := 0.0
var solve_step := 1.0

export var color_bright := Color.white
export var color_dark := Color("bfbfbf")

func _enter_tree():
	Shared.connect("scene_changed", self, "scene")
	get_tree().connect("idle_frame", self, "idle_frame")

func _ready():
	hide.visible = false
	particles.emitting = false
	particles.visible = false
	
	yield(Shared, "scene_changed")
	randomize()
	self.is_rain = randf() < 0.3

func scene():
	center.global_position = Shared.boundary_center
	precip.global_position = Shared.boundary_center
	length = Shared.boundary_rect.size.length() / 2.0
	#print("x: ", Shared.boundary_rect.size.x / 2.0, " y: ", Shared.boundary_rect.size.y / 2.0, " length(): ", Shared.boundary_rect.size.length() / 2.0, " length: ", length)
	
	star_orbit.position = Vector2(length + orbit_distance, 0)
	moon.scale.x = -1 if randf() < 0.5 else 1.0
	
	is_snow = "2A/" in Shared.csfn or "3B/" in Shared.csfn
	create_clouds()
	solve_clock = 0.0
	
	if audio_rain:
		audio_rain.playing = is_rain and !is_snow

func _process(delta):
	# visible
	sun_frac = ease(abs(bg.frac - 0.5) * 2.0, -9)
	moon_frac = 1.0 - sun_frac
	
	sun.modulate.a = sun_frac
	moon.modulate.a = moon_frac
	starfield.modulate.a = moon_frac
	starfield.visible = moon_frac > 0
	canvas_mod.color = color_bright.linear_interpolate(color_dark, moon_frac)
	
	# rotation
	star_rotation = bg.frac * TAU
	stars.rotation = star_rotation
	starfield.rotation = star_rotation
	
	cloud_rotation = fposmod(cloud_rotation + deg2rad(cloud_speed * delta * cloud_dir), TAU)
	clouds.rotation = cloud_rotation
	clouds1.rotation = cloud_rotation
	clouds2.rotation = cloud_rotation
	precip.rotation = cloud_rotation

func idle_frame():
	# parallax
	var par = Cam.global_position - Shared.boundary_center
	clouds1.position = par * 0.3
	clouds2.position = par * 0.6
	starfield.position = par * 0.9

func _physics_process(delta):
	rain_clock -= delta
	if rain_clock < 0:
		self.is_rain = !is_rain 
	
	if is_rain:
		solve_clock -= delta
		if solve_clock < 0:
			solve_clock += solve_step
			solve_fall()

func set_is_rain(arg := is_rain):
	is_rain = arg
	var vec = rain_range if is_rain else dry_range
	rain_clock = rand_range(vec.x, vec.y)
	print("is_rain: ", is_rain, " audio: ", audio_rain, " precip_list: ", precip_list.size())
	
	for i in precip_list:
		i.emitting = is_rain
	solve_fall()

	if audio_rain:
		audio_rain.playing = is_rain and !is_snow

func create_clouds():
	cloud_dir = (-1.0 if randf() > 0.5 else 1.0) * rand_range(0.6, 1.0)
	precip_list = []
	var ci = 0
	var bi = 0
	var wi = 0
	var pi = 0
	var pc = precip.get_children()
	var ps = pc.size()
	
	for x in (length / 50.0) + cloud_bonus_rings:
		for y in max(3, x):
			var angle = rand_range(0.0, TAU)
			var dist = ((x + 2) * 200) + rand_range(0.0, 100.0)
			var pos = Vector2(dist, 0).rotated(angle)
			var scl = Vector2.ONE * rand_range(0.25, 2.0)
			
			var way_back := randf() > 0.5
			var is_front = dist > length + cloud_front_range.x
			var is_precip = dist < length + cloud_front_range.y
			if is_front and !is_precip: is_front = randf() > 0.5
			var layer = 0 if is_front else 2 if way_back else 1
			
			var t = Transform2D(randf() * TAU, Vector2.ZERO)
			t = t.scaled(scl)
			t.origin = pos
			([clouds, clouds1, clouds2][layer]).multimesh.set_instance_transform_2d([ci, bi, wi][layer], t)
			
			match layer:
				0: ci += 1
				1: bi += 1
				2: wi += 1
			
			if is_front and is_precip:
				var p = null
				if pi < ps:
					p = pc[pi]
					pi += 1
				else:
					p = particles.duplicate()
					precip.add_child(p)
					p.owner = precip
				
				p.amount = scl.x * (200 if is_snow else 100)
				p.texture = snow_tex if is_snow else rain_tex
				p.process_material = (snow_mat if is_snow else rain_mat).duplicate()
				p.process_material.emission_sphere_radius = scl.x * 150.0
				p.process_material.emission_box_extents = Vector3(scl.x * 175.0, 100, 0)
				
				p.position = pos
				p.rotation = angle + (PI/2.0)
				
				p.visible = true
				p.emitting = is_rain
				
				precip_list.append(p)
	
	# clouds
	for i in 3:
		[clouds, clouds1, clouds2][i].multimesh.visible_instance_count = [ci, bi, wi][i]
	
	# particles
	if pi < ps:
		for a in range(max(pi, 0), ps):
			pc[a].visible = false
			pc[a].emitting = false

func solve_fall():
	for i in precip_list:
		var r = i.get_child(0)
		var rp = r.get_collision_point()
		var d = r.global_position.distance_to(rp)
		i.lifetime = (d / i.process_material.initial_velocity)
		
