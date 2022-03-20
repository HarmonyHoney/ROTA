tool
extends Door

onready var gems := $Gems
onready var gem := $Gems/Gem

export var is_gem := false
export var gem_count := 1
export var gem_radius := 60.0
export(String, DIR) var gem_world := ""
var gems_collected := 0

func _enter_tree():
	if Engine.editor_hint: return
	
	if is_gem:
		Shared.door_goal = self

func _ready():
	if Engine.editor_hint: return
	
	CheatCode.connect("activate", self, "cheat_code")
	
	if is_gem:
		
		# gems collected
		if gem_world != "":
			for i in Shared.goals_collected:
				if i.begins_with(gem_world):
					gems_collected += 1
		
		# create gems
		for i in gem_count:
			var g = gem
			if i > 0:
				g = gem.duplicate()
				gems.add_child(g)
				g.owner = self
			var angle = (float(i) / float(gem_count)) * TAU
			g.position = Vector2(0, gem_radius).rotated(angle)
			g.rotation = angle
		
		# color gems
		for i in gem_count:
			if i < gems_collected:
				gems.get_child(i).set_color()
		
		is_locked = gems_collected < gem_count
	else:
		gems.visible = false

# unlock cheat
func cheat_code(cheat):
	if "konami" in cheat and is_locked:
		unlock()

func unlock():
	is_locked = false
	arrow.visible = true
	print(name, " unlocked")
