extends CanvasLayer

onready var sprite : CanvasItem = $TextureRect
onready var mat : ShaderMaterial = sprite.material

signal start
signal complete

var is_wipe := false
var is_in := false
var is_intro := false

var radius := 0.71
var easy = EaseMover.new()

var delay := 0.0

func _ready():
	sprite.visible = false

func _process(delta):
	if delay > 0.0:
		delay -= delta
		if delay < 0.0 and !is_in: Audio.play("menu_wipe", 0.9, 1.1)
	elif is_wipe:
		var s = easy.count(delta, !is_in)
		mat.set_shader_param("radius", s * radius)
		sprite.visible = easy.clock > 0.0
		
		is_intro = is_in and easy.frac() > 0.33
		
		if (easy.clock == 0 and is_in) or (easy.is_complete and !is_in):
			is_wipe = false
			emit_signal("complete", is_in)

func start(arg := false, _delay := 0.0):
	is_in = arg
	is_intro = is_in
	is_wipe = true
	delay = max(0.001, _delay)
	easy.clock = easy.time if is_in else 0
	emit_signal("start", is_in)
