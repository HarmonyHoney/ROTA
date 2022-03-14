extends Node2D

onready var gems := $Gems
onready var gem := $Gems/Gem

export var is_gem := true
export var gem_count := 1
export var gem_radius := 60.0
export var gem_world := ""

var gems_collected := 0

func _enter_tree():
	Shared.slab = self

func _ready():
	if is_gem:
		
		# gems collected
		if gem_world != "":
			for i in Shared.goals_collected:
				if i.begins_with(gem_world):
					gems_collected += 1
		else:
			gems_collected = Shared.goals_collected.size()
		
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
	else:
		gems.visible = false
	
	
	if gems_collected >= gem_count:
		if !Shared.slabs_completed.has(Shared.csfn):
			Shared.slabs_completed.append(Shared.csfn)
	
