tool
extends Door

onready var gem := $Gem

func _ready():
	if Engine.editor_hint: return
	
	if "hub" in scene_path:
		gem.visible = false
	elif Shared.goals_collected.has(scene_path):
		gem.set_color()

# acquire goal
func on_enter():
	if is_instance_valid(Shared.goal):
		if Shared.goal.is_collected and !Shared.goals_collected.has(Shared.csfn):
			Shared.goals_collected.append(Shared.csfn)
			Shared.is_collect = true
	
	if not "hub" in scene_path:
		Shared.is_show_goal = true
