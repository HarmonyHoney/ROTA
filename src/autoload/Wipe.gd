extends CanvasLayer

onready var sprite : Sprite = $Sprite
onready var audio := $AudioStreamPlayer
onready var mat : ShaderMaterial = $Sprite.material

signal wipe_in
signal wipe_out

signal start_wipe_in
signal start_wipe_out

var is_wipe := false
var is_in := false

var clock := 0.0
var time := 0.5
var radius := 0.71

func _ready():
	sprite.visible = false

func _process(delta):
	if is_wipe:
		clock = clamp(clock + (-delta if is_in else delta), 0, time)
		var s = smoothstep(0, 1, clock / time)
		
		mat.set_shader_param("radius", lerp(0, radius, s))
		
		if (clock == 0 and is_in) or (clock == time and !is_in):
			is_wipe = false
			sprite.visible = false
			emit_signal("wipe_in") if is_in else emit_signal("wipe_out")

func start(arg := false):
	is_in = arg
	is_wipe = true
	sprite.visible = true
	clock = time if is_in else 0
	emit_signal("start_wipe_in") if is_in else emit_signal("start_wipe_out")
	
	if !is_in:
		audio.pitch_scale = rand_range(0.9, 1.1)
		audio.play()
	
