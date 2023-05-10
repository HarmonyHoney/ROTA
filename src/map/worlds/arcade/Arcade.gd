extends Node2D

onready var player = Shared.player


onready var btn_joy := $CanvasLayer/Cabinet/Controls/Joystick
onready var btn_a := $CanvasLayer/Cabinet/Controls/Button/Control/Node2D
onready var btn_b := $CanvasLayer/Cabinet/Controls/Button2/Control/Node2D

var joy := Vector2.ZERO

func _ready():
	player.is_input = false
	Cam.target_node = null
	Cam.target_pos = Vector2(1280, 720) * 0.5
	
func _exit_tree():
	player.is_input = true
	Cam.target_node = player


func _physics_process(delta):
	
	joy.x = round(Input.get_axis("left", "right"))
	#joy.y = round(Input.get_axis("up", "down"))
	var _a = Input.is_action_pressed("jump")
	var _b = Input.is_action_pressed("grab")
	
	btn_joy.rotation = lerp(btn_joy.rotation, joy.x * deg2rad(15), delta * 30.0)
	btn_a.position.y = lerp(btn_a.position.y, float(_a) * 20, delta * 30.0)
	btn_b.position.y = lerp(btn_b.position.y, float(_b) * 20, delta * 30.0)
	
	pass
