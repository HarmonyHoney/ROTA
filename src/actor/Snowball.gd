extends Area2D

export var dir := 0
export var snow_gravity := Vector2(0, 120)
export var velocity := Vector2.ZERO
export var term_vel := 1000

onready var polygon := $Polygon2D

var is_hit := false
var is_out := false
var lifetime := 0.0
var life_min := 0.3

var hit_easy := EaseMover.new()

func _ready():
	pass
	
func _physics_process(delta):
	if is_out: return
	lifetime += delta
	
	if is_hit:
		polygon.scale = Vector2.ONE * (1.0 - hit_easy.count(delta))
		
		if hit_easy.is_complete:
			print(name, " is out")
			is_out = true
	else:
		velocity += snow_gravity * delta
		velocity.y = clamp(velocity.y, -term_vel, term_vel)
		global_position += rot(velocity * delta)


func rot(vec : Vector2, _dir := dir) -> Vector2:
	_dir = posmod(_dir, 4)
	match _dir:
		1: return Vector2(-vec.y, vec.x)
		2: return Vector2(-vec.x, -vec.y)
		3: return Vector2(vec.y, -vec.x)
	return vec

func area_entered(area):
	if lifetime > life_min:
		#is_hit = true
		print(name, " ", area)

func body_entered(body):
	if lifetime > life_min:
		is_hit = true
		print(name, " ", body)
