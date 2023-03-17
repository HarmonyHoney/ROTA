extends Node2D

onready var hide := $Hide
onready var cloud := $Hide/Cloud
onready var color_rect := $Hide/ColorRect
onready var particles := $Hide/Particles2D

onready var center := $Center
onready var clouds := $Center/Clouds
onready var stars := $Center/Stars
onready var sun := $Center/Stars/Sun
onready var moon := $Center/Stars/Moon
onready var precip := $Center/Fall

export var cloud_speed := 1.0
export var star_speed := 0.5
var cloud_dir := 1.0
var star_dir := 1.0

var length = 100.0
var dir := 1.0
var speed_mod := 1.0

var clock := 0.0
var step := 1.0

export var snow_mat : ParticlesMaterial
export var snow_tex : Texture
export var rain_mat : ParticlesMaterial
export var rain_tex : Texture

func _enter_tree():
	Shared.connect("scene_changed", self, "scene")

func _ready():
	hide.visible = false
	particles.emitting = false
	particles.visible = false

func scene():
	var start = Vector2.ONE * 900
	var end = Vector2.ONE * -900

	for i in get_tree().get_nodes_in_group("solid_map"):
		for c in i.get_used_cells():
			start.x = min(start.x, c.x)
			start.y = min(start.y, c.y)
			end.x = max(end.x, c.x)
			end.y = max(end.y, c.y)
	
	global_position = (start.linear_interpolate(end, 0.5) + (Vector2.ONE * 0.5)) * 100.0
	color_rect.rect_size = ((end - start) + Vector2.ONE) * 100.0
	color_rect.rect_position = -color_rect.rect_size / 2.0
	length = max(color_rect.rect_size.x, color_rect.rect_size.y) / 2.0
	
	sun.position = Vector2(length + 650, 0)
	moon.position = -sun.position
	moon.scale.x = -1 if randf() < 0.5 else 1.0
	stars.rotation = rand_range(0.0, TAU)
	
	print("start: ", start, " end: ", end, " length: ", length, " global_position: ", global_position)
	
	cloud_dir = (-1.0 if randf() > 0.5 else 1.0) * rand_range(0.6, 1.0)
	star_dir = (-1.0 if randf() > 0.5 else 1.0) * rand_range(0.6, 1.0)
	#speed_mod = rand_range(0.6, 1.0) * dir
	create_clouds()
	yield(get_tree(), "physics_frame")
	solve_fall()

func _physics_process(delta):
	clouds.rotate(deg2rad(cloud_speed * delta * cloud_dir))
	precip.rotation = clouds.rotation
	stars.rotation = BG.frac * TAU
	stars.rotate(deg2rad(star_speed * delta * -star_dir))
	
	var sunf = ease(abs(BG.frac - 0.5) * 2.0, -7)
	sun.modulate.a = sunf
	moon.modulate.a = 1.0 - sunf
	$Center/Stars/Stars.modulate.a = 1.0 - sunf
	
	clock += delta
	if clock > step:
		clock -= step
		solve_fall()

func create_clouds():
	var ci = -1
	var pi = -1
	var gc = clouds.get_children()
	var gcs = gc.size()
	var pc = precip.get_children()
	var pcs = pc.size()
	var is_snow = "2A/" in Shared.csfn or "3B" in Shared.csfn
	var is_rain = (randf() > 0.8) and (Shared.map_name != "")
	print("smn: ", Shared.map_name, " is_rain: ", is_rain, " is_snow: ", is_snow)
	
	
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
						#p.process_material = p.process_material.duplicate()
					
					p.process_material = (snow_mat if is_snow else rain_mat).duplicate()
					p.texture = snow_tex if is_snow else rain_tex
					p.amount = c.scale.x * (200 if is_snow else 100)
					p.lifetime = 9.0 if is_snow else 3.0
					
					p.position = c.position
					p.rotation = angle + (PI/2.0)
					p.process_material.emission_sphere_radius = c.scale.x * 150.0
					
					p.visible = is_snow or is_rain
					p.emitting = is_snow or is_rain
	
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
	for i in precip.get_children():
		var r = i.get_child(0)
		var rp = r.get_collision_point()
		var d = r.global_position.distance_to(rp)
		#print(i.name, " ", d)
		i.lifetime = (d / i.process_material.initial_velocity)
