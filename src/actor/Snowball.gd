extends Area2D

export var dir := 0
export var snow_gravity := Vector2(0, 120)
export var throw_vel := Vector2(500, -50)
export var velocity := Vector2.ZERO
var term_vel := 1000

onready var polygon := $Polygon2D
onready var audio_hit := $Audio/Hit
onready var audio_throw := $Audio/Throw

var is_hit := false
var is_out := false
var lifetime := 0.0
export var life_range := Vector2(0.1, 10.0)

var throw_easy := EaseMover.new(0.1)
var hit_easy := EaseMover.new()

func _ready():
	pass
	
func _physics_process(delta):
	if is_out: return
	lifetime += delta
	
	if is_hit:
		polygon.scale = Vector2.ONE * (1.0 - hit_easy.count(delta))
		
		if hit_easy.is_complete:
			is_out = true
			#print(name, " is out")
	else:
		velocity += snow_gravity * delta
		velocity.y = clamp(velocity.y, -term_vel, term_vel)
		global_position += rot(velocity * delta)
		
		polygon.scale = Vector2.ONE * lerp(0.5, 1.0, throw_easy.count(delta))
		
		if lifetime > life_range.y:
			hit()


func rot(vec : Vector2, _dir := dir) -> Vector2:
	_dir = posmod(_dir, 4)
	match _dir:
		1: return Vector2(-vec.y, vec.x)
		2: return Vector2(-vec.x, -vec.y)
		3: return Vector2(vec.y, -vec.x)
	return vec

func area_entered(area):
	if lifetime > life_range.x and (!area.get_collision_layer_bit(4) or area.get_collision_layer_bit(6)):
		hit()

func body_entered(body):
	if lifetime > life_range.x:
		hit()

func hit():
	if !is_hit:
		is_hit = true
		hit_easy.clock = 0.0
		Audio.play(audio_hit, 0.8, 1.2)

func throw(from := Vector2.ZERO, vel := throw_vel, _dir := dir):
	global_position = from
	velocity = vel
	dir = _dir
	is_out = false
	is_hit = false
	throw_easy.clock = 0
	lifetime = 0
	polygon.scale = Vector2.ONE
	Audio.play(audio_throw, 0.8, 1.2)
