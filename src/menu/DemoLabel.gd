extends CanvasItem

var is_active := false

var fade = EaseMover.new()

func _ready():
	visible = Shared.is_demo

func _physics_process(delta):
	fade.count(delta, is_active)
	modulate.a = fade.smooth()

func _on_Area2D_area_entered(area):
	is_active = true

func _on_Area2D_area_exited(area):
	is_active = false
