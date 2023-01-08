extends CanvasItem

var fade = EaseMover.new()
export var is_demo := false

func _ready():
	visible = Shared.is_demo if is_demo else true
	fade.show = false

func _physics_process(delta):
	modulate.a = fade.count(delta)

func _on_Area2D_area_entered(area):
	fade.show = true

func _on_Area2D_area_exited(area):
	fade.show = false
