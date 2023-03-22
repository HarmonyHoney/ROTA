extends Node2D

onready var hide := $Hide
onready var cloud := $Hide/Cloud
onready var color_rect := $Hide/ColorRect
onready var particles := $Hide/Particles2D

onready var center := $Center
onready var clouds := $Center/Clouds
onready var stars := $Center/Stars
onready var sun := $Center/Stars/Sun
onready var sun_light := $Center/Stars/Sun/Light2D
onready var moon := $Center/Stars/Moon
onready var moon_light := $Center/Stars/Moon/Light2D
onready var night_sky := $Center/Stars/Stars
onready var precip := $Center/Fall
onready var audio_rain := $AudioRain
onready var darkness := $Front/ColorRect
onready var bg := $BG

export var cloud_speed := 1.0
var cloud_dir := 1.0
var length = 100.0

var solve_clock := 0.0
var solve_step := 1.0

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


func _enter_tree():
	Shared.connect("scene_changed", self, "scene")

func _ready():
	hide.visible = false
	particles.emitting = false
	particles.visible = false
	
	yield(Shared, "scene_changed")
	randomize()
	self.is_rain = randf() < 0.3

func scene():
	global_position = Shared.boundary_center
	color_rect.rect_size = Shared.boundary_rect.size
	color_rect.rect_position = -color_rect.rect_size / 2.0
	length = max(color_rect.rect_size.x, color_rect.rect_size.y) / 2.0
	
	sun.position = Vector2(length + 650, 0)
	moon.position = -sun.position
	moon.scale.x = -1 if randf() < 0.5 else 1.0
	
	is_snow = "2A/" in Shared.csfn or "3B/" in Shared.csfn
	create_clouds()
	solve_clock = 0.0
	
	if audio_rain:
		audio_rain.playing = is_rain and !is_snow

func _physics_process(delta):
	clouds.rotate(deg2rad(cloud_speed * delta * cloud_dir))
	precip.rotation = clouds.rotation
	stars.rotation = bg.frac * TAU
	
	sun_frac = ease(abs(bg.frac - 0.5) * 2.0, -7)
	moon_frac = 1.0 - sun_frac
	
	sun.modulate.a = sun_frac
	sun_light.energy = sun_frac * 0.4
	sun_light.enabled = sun_frac > 0
	
	moon.modulate.a = moon_frac
	moon_light.energy = moon_frac * 0.5
	moon_light.enabled = moon_frac > 0
	night_sky.modulate.a = moon_frac
	darkness.self_modulate.a = moon_frac
	
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
	var ci = -1
	var pi = -1
	var gc = clouds.get_children()
	var gcs = gc.size()
	var pc = precip.get_children()
	var pcs = pc.size()
	
	
	for x in (length / 50.0) + 5:
		for y in max(3, x):
			ci += 1
			var c = null
			if ci < gcs:
				c = gc[ci]
			else:
				c = cloud.duplicate()
				clouds.add_child(c)
				c.owner = clouds
			
			var angle = rand_range(0.0, TAU)
			c.position = Vector2(((x + 2) * 200) + rand_range(0.0, 100.0), 0).rotated(angle)
			c.scale = Vector2.ONE * rand_range(0.25, 2.0)
			c.rotation = randf() * TAU
			c.visible = true
			c.color.a = 0.3
			
			var cpl = c.position.length()
			if cpl > length + 500:
				#c.color.a = lerp(c.color.a, 1.0, clamp((cpl - (length + 700)) / 500.0, 0, 1))
				c.color.a = 0.8
				
				if cpl < length + 1000:
					pi += 1
					var p = null
					if pi < pcs:
						p = pc[pi]
					else:
						p = particles.duplicate()
						precip.add_child(p)
						p.owner = precip
					
					p.amount = c.scale.x * (200 if is_snow else 100)
					p.texture = snow_tex if is_snow else rain_tex
					p.process_material = (snow_mat if is_snow else rain_mat).duplicate()
					p.process_material.emission_sphere_radius = c.scale.x * 150.0
					p.process_material.emission_box_extents = Vector3(c.scale.x * 175.0, 100, 0)
					
					p.position = c.position
					p.rotation = angle + (PI/2.0)
					
					p.visible = true
					p.emitting = is_rain
					
					precip_list.append(p)
	
	# clouds
	if ci < gcs:
		for a in range(max(ci, 0), gcs):
			gc[a].visible = false
	# particles
	if pi < pcs:
		for a in range(max(pi, 0), pcs):
			pc[a].visible = false
			pc[a].emitting = false

func solve_fall():
	for i in precip_list:
		var r = i.get_child(0)
		var rp = r.get_collision_point()
		var d = r.global_position.distance_to(rp)
		i.lifetime = (d / i.process_material.initial_velocity)
		
