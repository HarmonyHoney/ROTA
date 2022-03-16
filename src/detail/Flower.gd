tool
extends PaletteSwap

export var is_pot := false setget set_pot
# colors ["FFF", "FF0000", "FF78CB", "79FFFF", "FFFA00", "FFC900"]

func set_pot(arg : bool):
	is_pot = arg
	
	if $Sprites and $Area2D:
		$Sprites/Flower.position.y = -150 * int(is_pot)
		$Sprites/Pot.visible = is_pot
		$Area2D.position.y = -45 if is_pot else -25
	
	z_index = 1 if is_pot else -10
