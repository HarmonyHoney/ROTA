extends Line2D

export var length = 25
export var gravity = 200.0
export var sitting_angle = 15.0
export var lerp_weight := 0.3

#export var radius = 53.0
#export var color = Color("ff007e")

#export var points := 10


var hair_end = Vector2(-150, 150)
var last_pos : Vector2 = position


func _physics_process(delta):
	
	# move end
	hair_end -= hair_end - to_local(last_pos)
	
	# gravity
	hair_end += Vector2.DOWN * gravity * delta
	
	# keep hair behind back
	var a = rad2deg(hair_end.angle()) - 90
	if abs(a) < sitting_angle:
		var diff = (sitting_angle - abs(a)) * global_scale.x
		var l = lerp(0,  deg2rad(diff), lerp_weight)
		hair_end = hair_end.rotated(l)
	
	# keep length
	if hair_end.length() > length:
		hair_end = hair_end.normalized() * length
	
	points[1] = hair_end
	
	last_pos = to_global(hair_end)

