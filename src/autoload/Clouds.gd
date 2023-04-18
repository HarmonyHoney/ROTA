tool
extends Node2D

export var is_editor := false setget set_is_editor
export var day_clock := 0.0
export var day_time := 420.0 setget set_day_time
export var day_scale := 1.0 setget set_day_scale
export(Array, Color) var sky_pal = [Color("ffa300"), Color("00e0ff"), Color("0062ff"), Color("ac00ff"), Color("af00bf"), Color("250000")] setget set_sky_pal
onready var sky_mat : ShaderMaterial = $BG/ColorRect.material

var day_frac = 0.0
var sky_step := 0
var step_time := 1.0
var step_frac := 0.0

onready var canvas_mod := $CanvasModulate
onready var hide := $Hide
onready var particles := $Hide/Particles2D

onready var center := $Sky/Center
onready var clouds := $Sky/Center/Clouds
onready var clouds1 := $Sky/Center/Clouds1
onready var clouds2 := $Sky/Center/Clouds2
onready var clouds_rain := $Sky/Center/CloudsRain
onready var precip := $Precip
onready var audio_rain := $AudioRain

onready var stars := $Sky/Center/Stars
onready var starfield := $Sky/Center/Starfield
onready var star_orbit := $Sky/Center/Stars/Orbit
onready var star_light := $Sky/Center/Stars/Orbit/Light2D
onready var star_energy : float = star_light.energy
onready var sun := $Sky/Center/Stars/Orbit/Sun
onready var moon := $Sky/Center/Stars/Orbit/Moon
onready var moon_mat : ShaderMaterial = moon.material

export var orbit_distance := 650.0
export var cloud_speed := 1.0
var cloud_dir := 1.0
var length = 100.0
var cloud_rotation := 0.0
var star_rotation := 0.0
export var cloud_bonus_rings := 5
export var cloud_front_edge = 0.0
export var cloud_rain_range = Vector2(100, 400)

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
	if Engine.editor_hint: return
	
	Shared.connect("scene_changed", self, "scene")
	Cam.connect("moved", self, "cam_moved")

func _ready():
	star_light.enabled = !Engine.editor_hint
	
	if Engine.editor_hint: return
	
	set_sky_pal()
	
	hide.visible = false
	particles.emitting = false
	particles.visible = false
	
	randomize()
	day_clock = randf() * day_time
	
	yield(Shared, "scene_changed")
	self.is_rain = randf() < 0.3

func scene():
	center.global_position = Shared.boundary_center
	precip.global_position = Shared.boundary_center
	length = Shared.boundary_rect.size.length() / 2.0
	#print("x: ", Shared.boundary_rect.size.x / 2.0, " y: ", Shared.boundary_rect.size.y / 2.0, " length(): ", Shared.boundary_rect.size.length() / 2.0, " length: ", length)
	
	star_orbit.position = Vector2(length + orbit_distance, 0)
	moon.scale.x = -1 if randf() < 0.5 else 1.0
	
	is_snow = "2A/" in Shared.csfn or "2C/" in Shared.csfn
	create_clouds()
	solve_clock = 0.0
	
	if audio_rain:
		audio_rain.playing = is_rain and !is_snow

func _process(delta):
	if Engine.editor_hint and !is_editor: return
	
	day_clock = fposmod(day_clock + (delta * day_scale), day_time)
	day_frac = day_clock / day_time
	
	step_frac = fposmod(day_clock, step_time) / step_time
	sky_step = posmod((day_clock / step_time) + 2, sky_pal.size())
	
	if sky_mat and moon_mat:
		for i in 2:
			for m in [sky_mat, moon_mat]:
				m.set_shader_param("col" + str(i + 1), sky_pal[sky_step - 2 - i].linear_interpolate(sky_pal[sky_step - 1 - i], step_frac))
	
	if Engine.editor_hint: return
	
	# visible
	sun_frac = ease(abs(day_frac - 0.5) * 2.0, -9)
	moon_frac = 1.0 - sun_frac
	
	moon.scale = Vector2.ONE * lerp(0.5, 1.0, moon_frac)
	sun.scale = Vector2.ONE * lerp(0.8, 1.0, sun_frac)
	moon_mat.set_shader_param("sun_frac", sun_frac)
	
	starfield.modulate.a = moon_frac
	starfield.visible = moon_frac > 0
	
	var mf = MenuMakeover.fade_ease
	canvas_mod.color = color_bright.linear_interpolate(color_dark, max(moon_frac - mf.smooth(), 0.0))
	if !mf.is_last:
		star_light.energy = lerp(star_energy, 0.0, mf.smooth())
	
	# rotation
	star_rotation = day_frac * TAU
	for i in [stars, starfield]:
		i.rotation = star_rotation
	
	cloud_rotation = fposmod(cloud_rotation + deg2rad(cloud_speed * delta * cloud_dir * day_scale), TAU)
	for i in [clouds, clouds1, clouds2, clouds_rain, precip]:
		i.rotation = cloud_rotation

func cam_moved():
	# parallax
	var par = Cam.global_position - Shared.boundary_center
	clouds.position = par * 0.15
	clouds1.position = par * 0.3
	clouds2.position = par * 0.6
	starfield.position = par * 0.9

func _physics_process(delta):
	if Engine.editor_hint: return
	
	rain_clock -= delta * day_scale
	if rain_clock < 0:
		self.is_rain = !is_rain 
	
	if is_rain:
		solve_clock -= delta * day_scale
		if solve_clock < 0:
			solve_clock += solve_step
			solve_fall()

func set_is_editor(arg := is_editor):
	is_editor = arg
	if !is_editor:
		day_clock = 0.0
		if sky_mat:
			sky_mat.set_shader_param("col1", sky_pal[0])
			sky_mat.set_shader_param("col2", sky_pal[1])

func set_sky_pal(arg := sky_pal):
	sky_pal = arg
	set_day_time()

func set_day_time(arg := day_time):
	day_time = abs(arg)
	step_time = day_time / max(sky_pal.size(), 1.0)

func set_day_scale(arg := day_scale):
	day_scale = arg
	for i in precip_list:
		i.speed_scale = max(1.0, day_scale)

func set_is_rain(arg := is_rain):
	is_rain = arg
	if Engine.editor_hint: return
	
	var vec = rain_range if is_rain else dry_range
	rain_clock = rand_range(vec.x, vec.y)
	print("is_rain: ", is_rain, " audio: ", audio_rain, " precip_list: ", precip_list.size())
	
	for i in precip_list:
		i.emitting = is_rain
	solve_fall()

	if audio_rain:
		audio_rain.playing = is_rain and !is_snow
	
#	if clouds_rain:
#		clouds_rain.material.blend_mode = 2 if is_rain else 1

func set_is_weather(arg):
	for i in precip_list:
		i.visible = Shared.is_weather

func create_clouds():
	cloud_dir = (-1.0 if randf() > 0.5 else 1.0) * rand_range(0.6, 1.0)
	precip_list = []
	var pi = 0
	var pc = precip.get_children()
	var ps = pc.size()
	var layers = [[], [], [], []]
	
	for x in (length / 50.0) + cloud_bonus_rings:
		for y in max(3, x):
			var angle = rand_range(0.0, TAU)
			var scl = Vector2.ONE * rand_range(0.25, 2.0)
			var dist = ((x + 2) * 200) + rand_range(0.0, 100.0)
			var pos = Vector2(dist, 0).rotated(angle)
			var edge = dist - (scl.x * 200.0) - length
			
			var way_back := randf() > 0.5
			var is_front = edge > cloud_front_edge
			var is_precip = edge > cloud_rain_range.x and edge < cloud_rain_range.y
			if !is_precip and is_front: is_front = randf() > 0.5
			
			var layer = 3 if is_precip else 0 if is_front else 2 if way_back else 1
			
			var t = Transform2D(randf() * TAU, Vector2.ZERO)
			t = t.scaled(scl)
			t.origin = pos
			layers[layer].append(t)
			
			if is_precip:
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
				
				p.visible = Shared.is_weather
				p.emitting = is_rain
				
				precip_list.append(p)
	
	# clouds
	for i in 4:
		var mesh = [clouds, clouds1, clouds2, clouds_rain][i].multimesh
		var c = layers[i].size()
		mesh.instance_count = c
		
		for x in c:
			mesh.set_instance_transform_2d(x, layers[i][x])
	
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
		
