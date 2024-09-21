extends CanvasLayer

#class_name _ui

@onready var fps := $"%fps"
@onready var top_label := $"%top_label"
@onready var shop := $"%shop"
@onready var leaders_icons := $"%leaders_icons"
@onready var minimap := $"%minimap"
@onready var dialog := $"%dialog"
@onready var version_node := $"%version"
@onready var scoreboard := $"%score_board"
# STATS
@onready var stats := $"%stats"
var inventories : Node
var active_skills : Node
# CONTROLS
@onready var orders_panel := $"%orders_panel"
@onready var unit_controls_panel := $"%unit_controls_panel"
var orders_button : Node
var shop_button : Node
var unit_controls_button : Node
@onready var control_panel := $"%control_panel"
# MENUS
@onready var main_menu := $"%main_menu"
@onready var pause_menu := $"%pause_menu"
@onready var new_game_menu := $"%new_game_menu"
@onready var leader_select_menu := $"%leader_select_menu"

@onready var background := $"%waterfall_background"

func _ready():
	# stats
	inventories = stats.get_node("inventories")
	active_skills = stats.get_node("active_skills")
	# controls
	unit_controls_button = control_panel.get_node("%unit_controls_button")
	shop_button = control_panel.get_node("%shop_button")
	orders_button = control_panel.get_node("%orders_button")
	
	leader_select_menu.leader_selected.connect(new_game_menu.add_leader)
	
	hide_all()


func show_mid():
	hide_all()
	hide_menus()
	show()
	get_node("mid").show()


func show_main_menu():
	background.show()
	show_mid()
	show_version()
	main_menu.show()


func show_version():
	var parent = version_node.get_parent()
	for panel in parent.get_children():
		panel.hide()
	parent.show()
	version_node.show()


func hide_version():
	version_node.hide()


func show_pause_menu():
	show_mid()
	pause_menu.show()


func hide_menus():
	main_menu.hide()
	pause_menu.hide()
	new_game_menu.hide()
	leader_select_menu.hide()
	get_node("mid").hide()


func hide_all():
	hide_minimap()
	hide_version()
	for panel in self.get_children():
		panel.hide()


func show_all():
	show_minimap()
	for panel in self.get_children():
		panel.show()


func show_minimap():
	minimap.show()
	minimap.minimap_container.show()
	minimap.rect_layer.show()


func hide_minimap():
	minimap.hide()
	minimap.minimap_container.hide()
	minimap.rect_layer.hide()


func map_loaded():
	buttons_update()
	orders_panel.build()


func process(delta):
	if WorldState.get_state("game_started") and WorldState.get_state("show_fps"):
		var f = Engine.get_frames_per_second()
		var n = WorldState.get_state("all_units").size()
		fps.set_text("fps: "+str(f)+" u:"+str(n))
	
	# minimap display update
	if minimap:
		minimap.process(delta)
	
	if stats:
		stats.process(delta)
	
	if active_skills:
		active_skills.process(delta)
	
	# hud line
	if Behavior.path.path_line:
		Behavior.path.draw(WorldState.get_state("selected_unit"))


func hide_hpbars():
	for unit in WorldState.get_state("all_units"):
		if (unit != WorldState.get_state("selected_unit") and 
				unit.hud and
				unit.type != "leader" and
				unit.current_hp == Behavior.modifiers.get_value(unit, "hp") ):
					unit.hud.hpbar.hide()


func show_hpbars():
	for unit in WorldState.get_state("all_units"):
		if unit.hud: unit.hud.hpbar.show()


func show_select():
	if WorldState.get_state("selected_unit").is_controllable():
		orders_button.disabled = false
	orders_panel.update()
	buttons_update()


func hide_unselect():
	orders_panel.hide()
	orders_button.disabled = true
	unit_controls_panel.hide()
	unit_controls_button.disabled = true
	inventories.hide()
	shop.update_buttons()
	buttons_update()


func buttons_update():
	orders_button.set_pressed(orders_panel.visible)
	shop_button.set_pressed(shop.visible)
	unit_controls_button.set_pressed(unit_controls_panel.visible)
