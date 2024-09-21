extends TextEdit

func _gui_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER and has_focus():
			var code = text
			get_tree().get_current_scene().apply_cheat_code(code)
			text = ""
			release_focus()
