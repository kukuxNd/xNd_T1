extends Button

class_name Menu_button

var focus_color = get("custom_colors/font_color_focus")


func _on_Menu_button_mouse_entered():
	#set("custom_colors/font_color_hover", focus_color)
	grab_focus()
	pass


func _on_Menu_button_focus_exited():
	#set("custom_colors/font_color_hover", null)
	pass


func _on_Menu_button_focus_entered():
	#set("custom_colors/font_color_hover", focus_color)
	pass


func quick_start() -> void:
	pass # Replace with function body.


func _on_pressed() -> void:
	pass # Replace with function body.
