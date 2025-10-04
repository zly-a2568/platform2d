extends Control

var focus_node:Button

var rebinding_action:=""
var binding_node:Button

var keymap:KeyMapData=KeyMapData.new()


const KEY_DISPLAY_NAMES = {
	KEY_A: "A",
	KEY_B: "B",
	KEY_C: "C",
	KEY_D: "D",
	KEY_E: "E",
	KEY_F: "F",
	KEY_G: "G",
	KEY_H: "H",
	KEY_I: "I",
	KEY_J: "J",
	KEY_K: "K",
	KEY_L: "L",
	KEY_M: "M",
	KEY_N: "N",
	KEY_O: "O",
	KEY_P: "P",
	KEY_Q: "Q",
	KEY_R: "R",
	KEY_S: "S",
	KEY_T: "T",
	KEY_U: "U",
	KEY_V: "V",
	KEY_W: "W",
	KEY_X: "X",
	KEY_Y: "Y",
	KEY_Z: "Z",
	
	KEY_0: "0",
	KEY_1: "1",
	KEY_2: "2",
	KEY_3: "3",
	KEY_4: "4",
	KEY_5: "5",
	KEY_6: "6",
	KEY_7: "7",
	KEY_8: "8",
	KEY_9: "9",
	
	KEY_F1: "F1",
	KEY_F2: "F2",
	KEY_F3: "F3",
	KEY_F4: "F4",
	KEY_F5: "F5",
	KEY_F6: "F6",
	KEY_F7: "F7",
	KEY_F8: "F8",
	KEY_F9: "F9",
	KEY_F10: "F10",
	KEY_F11: "F11",
	KEY_F12: "F12",
	
	KEY_ESCAPE: "Esc",
	KEY_TAB: "Tab",
	KEY_BACKSPACE: "Backspace",
	KEY_ENTER: "Enter",
	KEY_SPACE: "Space",
	KEY_SHIFT: "Shift",
	KEY_CTRL: "Ctrl",
	KEY_ALT: "Alt",
	KEY_CAPSLOCK: "Caps Lock",
	KEY_MENU: "菜单",
	
	KEY_LEFT: "←",
	KEY_RIGHT: "→",
	KEY_UP: "↑",
	KEY_DOWN: "↓",
	
	KEY_BRACKETLEFT: "[",
	KEY_BRACKETRIGHT: "]",
	KEY_BRACELEFT: "{",
	KEY_BRACERIGHT: "}",
	KEY_QUOTELEFT: "`",
	KEY_QUOTEDBL: "\"",
	KEY_APOSTROPHE: "'",
	KEY_SEMICOLON: ";",
	KEY_COLON: ":",
	KEY_COMMA: ",",
	KEY_PERIOD: ".",
	KEY_SLASH: "/",
	KEY_BACKSLASH: "\\",
	KEY_BAR: "|",
	KEY_EXCLAM: "!",
	KEY_AT: "@",
	KEY_NUMBERSIGN: "#",
	KEY_DOLLAR: "$",
	KEY_PERCENT: "%",
	KEY_AMPERSAND: "&",
	KEY_ASTERISK: "*",
	KEY_PARENLEFT: "(",
	KEY_PARENRIGHT: ")",
	KEY_MINUS: "-",
	KEY_UNDERSCORE: "_",
	KEY_EQUAL: "=",
	KEY_PLUS: "+",
	
	KEY_KP_0: "Num 0",
	KEY_KP_1: "Num 1",
	KEY_KP_2: "Num 2",
	KEY_KP_3: "Num 3",
	KEY_KP_4: "Num 4",
	KEY_KP_5: "Num 5",
	KEY_KP_6: "Num 6",
	KEY_KP_7: "Num 7",
	KEY_KP_8: "Num 8",
	KEY_KP_9: "Num 9",
	KEY_KP_ADD: "Num +",
	KEY_KP_SUBTRACT: "Num -",
	KEY_KP_MULTIPLY: "Num *",
	KEY_KP_DIVIDE: "Num /",
	KEY_KP_PERIOD: "Num .",
	KEY_KP_ENTER: "Num Enter",
	
	KEY_PRINT: "Print Screen",
	KEY_SCROLLLOCK: "Scroll Lock",
	KEY_PAUSE: "Pause",
	KEY_INSERT: "Insert",
	KEY_DELETE: "Delete",
	KEY_HOME: "Home",
	KEY_END: "End",
	KEY_PAGEUP: "Page Up",
	KEY_PAGEDOWN: "Page Down"
}

# 获取键位的显示名称
func get_key_display_name(scancode: int) -> String:
	if KEY_DISPLAY_NAMES.has(scancode):
		return KEY_DISPLAY_NAMES[scancode]
	return "Unknown Key"

func open_panel():
	if FileAccess.file_exists(GameProcesser.KEYMAP_PATH):
		keymap=ResourceLoader.load(GameProcesser.KEYMAP_PATH) as KeyMapData
		for child in keymap.binding_nodes.keys():
			get_node(child).text=get_key_display_name(keymap.keymap[keymap.binding_nodes[child]])
		
	show()

func start_rebinding(node:Button,action:String):
	rebinding_action=action
	binding_node=node
	focus_node=get_viewport().gui_get_focus_owner()
	get_viewport().gui_release_focus()
	
func _unhandled_key_input(event: InputEvent) -> void:
	if rebinding_action!="" and binding_node!=null and event is InputEventKey and event.is_pressed():
		InputMap.action_erase_events(rebinding_action)
		
		InputMap.action_add_event(rebinding_action,event)
		binding_node.text=get_key_display_name((event as InputEventKey).keycode)
		keymap.keymap[rebinding_action]=(event as InputEventKey).keycode
		ResourceSaver.save(keymap,GameProcesser.KEYMAP_PATH)
		rebinding_action=""
		binding_node=null
		focus_node.grab_focus()


func _on_move_left_pressed() -> void:
	start_rebinding($VBoxContainer/GridContainer/MoveLeft,"ui_left")


func _on_move_right_pressed() -> void:
	start_rebinding($VBoxContainer/GridContainer/MoveRight,"ui_right")
	
func _on_jump_pressed() -> void:
	start_rebinding($VBoxContainer/GridContainer/Jump,"jump")


func _on_attack_pressed() -> void:
	start_rebinding($VBoxContainer/GridContainer/Attack,"attack")
	
func _on_flash_pressed() -> void:
	start_rebinding($VBoxContainer/GridContainer/Flash,"flash")

func _on_shoot_pressed() -> void:
	start_rebinding($VBoxContainer/GridContainer/Shoot,"shoot")


func _on_exit_pressed() -> void:
	hide()
	(self.get_parent().get_node("Panel/Panel/Settings") as Button).grab_focus()
