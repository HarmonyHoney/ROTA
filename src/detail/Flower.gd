tool
extends Node2D

onready var sprites := $Sprites
onready var petals := $Sprites/Flower/Petals

var colors = ["FF0000", "FF78CB", "79FFFF", "FFFA00"]
export var palette := 0 setget set_palette

var angle := 0.0
var velocity := 0.0
var target := 0.0

export var add_vel := 6.0
export var weight := 2.0

var cooldown_clock := 0.0
export var cooldown_time := 0.6

export var is_pot := false setget set_pot

func _ready():
	petal_color()

func _physics_process(delta):
	if Engine.editor_hint: return
	
	velocity = lerp(velocity, (target - angle) * 0.5, delta * weight)
	angle += velocity
	sprites.rotation_degrees = angle
	
	
	# cooldown
	cooldown_clock = max(cooldown_clock - delta, 0)


func set_palette(arg):
	palette = posmod(int(arg), 5)
	petal_color()

func petal_color():
	if petals:
		petals.modulate = Color.white if palette == 0 else Color(colors[palette - 1])

func hit(scale := 1.0):
	velocity += add_vel * scale

func set_pot(arg : bool):
	is_pot = arg
	
	if $Sprites and $Area2D:
		$Sprites/Flower.position.y = -150 * int(is_pot)
		$Sprites/Pot.visible = is_pot
		$Area2D.position.y = -45 if is_pot else -25
	
	z_index = 1 if is_pot else -10

func _on_Area2D_area_entered(area):
	if cooldown_clock == 0:
		hit(1 if to_local(area.global_position).x < 0 else -1)
		cooldown_clock = cooldown_time
