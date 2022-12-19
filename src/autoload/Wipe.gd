extends CanvasLayer

onready var sprite : Sprite = $Sprite
onready var mat : ShaderMaterial = sprite.material
onready var audio := $AudioStreamPlayer

signal start
signal complete

var is_wipe := false
var is_in := false

var radius := 0.71
var easy = EaseMover.new()

func _ready():
	sprite.visible = false

func _process(delta):
	if is_wipe:
		mat.set_shader_param("radius", easy.count(delta, !is_in) * radius)
		
		if (easy.clock == 0 and is_in) or (easy.clock == easy.time and !is_in):
			is_wipe = false
			sprite.visible = false
			emit_signal("complete", is_in)

func start(arg := false):
	is_in = arg
	is_wipe = true
	sprite.visible = true
	easy.clock = easy.time if is_in else 0
	emit_signal("start", is_in)
	
	if !is_in:
		audio.pitch_scale = rand_range(0.9, 1.1)
		audio.play()
