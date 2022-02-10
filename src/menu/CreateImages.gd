extends Node2D

var maps = "res://src/map/worlds/"
var preview = "res://src/map/preview/"
var hub = "res://src/map/hub/"

onready var viewport = $Viewport
onready var sprite = $Sprite

var map_textures = {}

var current = 0

var joy = Vector2.ZERO
var joy_last = joy

func _ready():
	
	var image_dict = {}
	
	sprite.scale = Vector2(1280, 720) / viewport.size
	
	yield(get_parent(), "ready")
	get_tree().paused = true
	
	var l = Shared.list_all_files(maps) + Shared.list_all_files(preview) + Shared.list_all_files(hub)
	
	for c in viewport.get_children():
		viewport.remove_child(c)
	
	for i in l.size():
		var scene = load(l[i]).instance()
		viewport.add_child(scene)
		scene.owner = viewport
		
		var cam = scene.get_node("Camera2D")
		var player = scene.get_node("Actors/Player")
		
		player.visible = false
		
		cam.rotation = deg2rad(player.dir * 90)
		cam.zoom = cam.start_zoom
		cam.force_update_scroll()
		
		for f in 1:
			yield(get_tree(), "idle_frame")
		
		var image = viewport.get_texture().get_data()
		image.flip_y()
		image.blit_rect(image, Rect2(Vector2(280, 0), Vector2.ONE * 720), Vector2.ZERO)
		image.crop(720, 720)
		
		var it = ImageTexture.new()
		it.create_from_image(image)
		
		map_textures[l[i]] = it
		sprite.texture = it
		
		viewport.remove_child(scene)
		
#		image_dict[l[i]] = {}
#		image_dict[l[i]]["width"] = image.get_width()
#		image_dict[l[i]]["height"] = image.get_height()
#		image_dict[l[i]]["use_mipmaps"] = image.has_mipmaps()
#		image_dict[l[i]]["data"] = image.get_data()
	
	get_tree().paused = false
	Shared.map_textures = map_textures.duplicate()
	get_tree().change_scene("res://src/map/hub/1.tscn")

func _input(event):
	joy_last = joy
	joy = Input.get_vector("left", "right", "up", "down").round()
	
	if joy.x != 0 and joy.x != joy_last.x:
		current = clamp(current + joy.x, 0, map_textures.size() - 1)
		sprite.texture = map_textures.values()[current]
		print(map_textures.keys()[current], " - ", map_textures.values()[current], " - ", map_textures.values()[current].get_size())
	elif joy.y != 0 and joy.y != joy_last.y:
		sprite.visible = !sprite.visible
	
