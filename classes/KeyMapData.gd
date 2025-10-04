extends Resource
class_name KeyMapData

@export var keymap:Dictionary={
	"ui_left":KEY_LEFT,
	"ui_right":KEY_RIGHT,
	"jump":KEY_SPACE,
	"attack":KEY_J,
	"flash":KEY_K,
	"shoot":KEY_M
}

@export var binding_nodes:Dictionary={
	"VBoxContainer/GridContainer/MoveLeft":"ui_left",
	"VBoxContainer/GridContainer/MoveRight":"ui_right",
	"VBoxContainer/GridContainer/Jump":"jump",
	"VBoxContainer/GridContainer/Attack":"attack",
	"VBoxContainer/GridContainer/Flash":"flash",
	"VBoxContainer/GridContainer/Shoot":"shoot"
}
