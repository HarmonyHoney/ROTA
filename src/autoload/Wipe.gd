extends CanvasLayer

onready var anim : AnimationPlayer = $AnimationPlayer
onready var sprite : Sprite = $Sprite
onready var audio := $AudioStreamPlayer

var shader_scale = 100.0

signal wipe_in
signal wipe_out

signal start_wipe_in
signal start_wipe_out

func _ready():
	sprite.visible = false
#	get_tree().get_root().connect("size_changed", self, "size_changed")
#
#func size_changed():
#	$Sprite.material.set_shader_param("scale", (get_viewport().size.x/ 1280) * shader_scale)

func _on_AnimationPlayer_animation_finished(anim_name):
	sprite.visible = false
	emit_signal("wipe_in") if anim_name == "in" else emit_signal("wipe_out")

func start(wipe_in := false):
	sprite.visible = true
	anim.play("in") if wipe_in else anim.play("out")
	anim.advance(0)
	emit_signal("start_wipe_in") if wipe_in else emit_signal("start_wipe_out")
	
	if !wipe_in:
		audio.pitch_scale = rand_range(0.9, 1.1)
		audio.play()
		pass
	
