extends MenuBase

export var sub_path : NodePath
onready var main_menu = get_node_or_null(sub_path)
onready var player = Shared.player
onready var title_mat : ShaderMaterial = $Map/Title.material

func _ready():
	UI.keys.show = true
	Cam.target_node = null
	Cam.snap_to(main_menu.pos, 0)
	Shared.save_slot = -1
	player.is_input = false
	randomize()
	MenuMakeover.preset()
	
	player.spr_easy.show = false
	if Wipe.is_wipe:
		yield(Wipe, "complete")
	player.spr_easy.show = true

func _exit_tree():
	UI.keys.show = false
	Cam.target_node = player
	player.is_input = true

func accept():
	sub_menu(main_menu)

func _process(delta):
	title_mat.set_shader_param("shadow_angle", -Clouds.day_frac)
	
