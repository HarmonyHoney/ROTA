extends CanvasItem

export var is_show := true

func _ready():
	visible = is_show if Shared.is_demo else !is_show
