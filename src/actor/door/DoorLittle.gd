tool
extends Door

onready var gem := $Gem
onready var clock := $Clock

func _ready():
	if Engine.editor_hint: return
	
	arrow.connect("activate", self, "activate")
	
	var m = scene_path.lstrip(Shared.worlds_path).rstrip(".tscn")
	clock.visible = Shared.goals.has(m) and Shared.goals[m] > 0 and Shared.speedruns.has(m) and Shared.goals[m] < Shared.speedruns[m]
	gem.visible = !clock.visible
	
	if "hub" in scene_path:
		gem.visible = false
	elif Shared.goals.has(m):
		gem.set_color()

func activate():
	if not "hub" in scene_path and scene_path.begins_with(Shared.worlds_path):
		var m = scene_path.lstrip(Shared.worlds_path).rstrip(".tscn")
		UI.clock_best.visible = Shared.goals.has(m) if arrow.is_active else false
		if UI.clock_best.visible:
			UI.clock_best.text = "Best: " + Shared.time_string(Shared.goals[m], true)
		
		UI.clock_goal.visible = Shared.speedruns.has(m) if arrow.is_active else false
		if UI.clock_goal.visible:
			UI.clock_goal.text = "Goal: " + Shared.time_string(Shared.speedruns[m], true)

# acquire goal
func on_enter():
	Shared.collect_gem()
