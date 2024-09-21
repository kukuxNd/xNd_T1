extends Control
var game:Node

# self = game.ui.orders_panel

var cleared = false

var tax_buttons = []

var leader_orders = {}
var lane_orders = {}
var mine_orders = {}
var blacksmith_orders = {}
var lumbermill_orders = {}
var camp_orders = {}
var outpost_orders = {}

var mine:Array = []
var blacksmith:Array = []
var lumbermill:Array = []
var camp:Array = []
var outpost:Array = []


var button_template:PackedScene = load("res://ui/buttons/order_button.tscn")

const order_types = {
	"leader_tactics": ["retreat","defend","default","attack"],
	"lane_tactics": ["defend","default","attack"],
	"priority": ["pawn", "leader", "building"],
	"camp_hire": ["infantry","ranged","mounted"],
	"taxes": ["low","medium","high"],
	"gold": ["collect", "destroy"],
	"lumberjack": ["hire", "dismiss"],
	"tower_upgrades": ["extra room","fire arrows","reinforce"],
	"pawn_upgrades": ["weapons","armor","boots"]
}

const hint_tooltips_tactics = {
	"retreat": "Retreats on first hit",
	"defend": "Retreats if less than half HP",
	"default": "Retreats if less than third HP",
	"attack": "Never retreats"
}

const hint_tooltips_hire = {
	"infantry": "Extra infantry, costs 5 gold",
	"ranged": "Extra archer, costs 10 gold",
	"mounted": "Extra mounted soldier, costs 15 gold"
}

const hint_tooltips_tax = {
	"low": "Abolish taxes (+25% conquer hp, +20% pawn hp)",
	"medium": "Default tax (1 gold/sec for each leader)",
	"high": "Double taxes (-25% conquer hp, -20% pawn hp)"
}

const hint_tooltips_gold = {
	"collect": "Sends gold to your castle after 16 sec",
	"destroy": "Explodes mine destroying gold after 4 sec",
}

const hint_tooltips_lumberjack = {
	"hire": "Hire lumberjack - 100 gold (allow buiding repair)",
	"dismiss": "Dismiss lumberjack",
}

const hint_tooltips_tower_upgrades = {
	"extra room": "allows 1 extra pawn inside",
	"fire arrows": "+10 extra damage for 250 gold",
	"reinforce": "+10 extra defense for 200 gold"
}

const hint_tooltips_pawn_upgrades = {
	"boots": "+5 extra movement for 180 gold",
	"weapons": "+5 extra damage for 250 gold",
	"armor": "+5 extra defense for 200 gold"
}

const hint_keys_up = ["q","w","e","r"]
const hint_keys_down = ["a","s","d","f"]


@onready var container = $"%container"

func _ready():
	game = get_tree().get_current_scene()
	
	hide()
	clear_placeholder()



func clear_placeholder():
	if not cleared:
		for placeholder in container.get_children():
			container.remove_child(placeholder)
			placeholder.queue_free()
		
		cleared = true


func build():
	setup_lanes()
	build_blacksmiths()
	if WorldState.get_state("map").neutrals.size() > 1:
		build_mines()
		build_lumbermills()
		build_camps()
		build_outposts()


# LEADERS

func build_leaders():
	for leader in WorldState.get_state("all_leaders"):
		var orders_container = {
			"node": VBoxContainer.new(),
			"leader": leader
		}
		container.add_child(orders_container.node)
		leader_orders[leader.name+leader.team] = orders_container
		setup_leader_buttons(orders_container)
	
	Behavior.orders.build_leaders()


func setup_leader_buttons(orders_container):
	var label = Utils.label("tactics")
	orders_container.node.add_child(label)
	setup_tactics(orders_container, order_types.leader_tactics)
	var label2 = Utils.label("priority")
	orders_container.node.add_child(label2)
	setup_priority(orders_container)
	update()


# LANES

func setup_lanes():
	for team in WorldState.teams:
		for lane in WorldState.get_state("map").get_node("lanes").get_children():
			var orders_container = {
				"node": VBoxContainer.new(),
				"type": "lane",
				"lane": lane.name,
				"team": team
			}
			container.add_child(orders_container.node)
			lane_orders[lane.name+team] = orders_container
			setup_lane_buttons(orders_container)


func setup_lane_buttons(orders_container):
	var label = Utils.label(orders_container.lane +"lane tactics")
	orders_container.node.add_child(label)
	setup_tactics(orders_container, order_types.lane_tactics)
	var label2 = Utils.label(orders_container.lane +" lane priority")
	orders_container.node.add_child(label2)
	setup_priority(orders_container)


# MINES

func build_mines():
	for building in mine:
		game.ui.inventories.gold_timer(building)
		building.channeling_timer = Timer.new()
		building.add_child(building.channeling_timer)
		
		var orders = {
			"node": VBoxContainer.new(),
			"mine": building
		}
		container.add_child(orders.node)
		var side = building.get_parent().name
		mine_orders[building.name+side] = orders
		setup_mine_buttons(orders)


func setup_mine_buttons(orders):
	var label = Utils.label("gold")
	orders.node.add_child(label)
	setup_gold(orders)
	var label2 = Utils.label("taxes")
	orders.node.add_child(label2)
	setup_taxes(orders)


func setup_gold(orders):
	var buttons_container = HBoxContainer.new()
	orders.node.add_child(buttons_container)
	var index = 0
	for order in order_types.gold:
		var button = button_template.instantiate()
		buttons_container.add_child(button)
		button.tooltip_text = hint_tooltips_gold[order]
		button.orders = {
			"order": orders,
			"type": "gold",
			"gold": order,
			"hint": hint_keys_up[index]
		}
		index += 1
		setup_order_button(button)
	orders.node.add_child(HSeparator.new())


# BLACKSMITH

func build_blacksmiths():
	for building in blacksmith:
		var orders = {
			"node": VBoxContainer.new(),
			"blacksmith": building
		}
		container.add_child(orders.node)
		var side = building.get_parent().name
		blacksmith_orders[building.name+side] = orders
		setup_blacksmith_buttons(orders)


func setup_blacksmith_buttons(orders):
	var label = Utils.label("pawn upgrades")
	orders.node.add_child(label)
	setup_pawn_upgrades(orders)
	var label2 = Utils.label("taxes")
	orders.node.add_child(label2)
	setup_taxes(orders)


func setup_pawn_upgrades(orders):
	var buttons_container = HBoxContainer.new()
	orders.node.add_child(buttons_container)
	var index = 0
	for upgrade in order_types.pawn_upgrades:
		var button = button_template.instantiate()
		buttons_container.add_child(button)
		button.tooltip_text = hint_tooltips_pawn_upgrades[upgrade]
		button.orders = {
			"order": orders,
			"type": "pawn_upgrades",
			"pawn_upgrades": upgrade,
			"hint": hint_keys_up[index]
		}
		index += 1
		setup_order_button(button)
	orders.node.add_child(HSeparator.new())



# LUMBERMILL

func build_lumbermills():
	for building in lumbermill:
		var orders = {
			"node": VBoxContainer.new(),
			"lumbermill": building
		}
		container.add_child(orders.node)
		var side = building.get_parent().name
		lumbermill_orders[building.name+side] = orders
		setup_lumbermill_buttons(orders)


func setup_lumbermill_buttons(orders):
	var label = Utils.label("hire")
	orders.node.add_child(label)
	setup_lumberjack(orders)
	var label2 = Utils.label("taxes")
	orders.node.add_child(label2)
	setup_taxes(orders)


func setup_lumberjack(orders):
	var buttons_container = HBoxContainer.new()
	orders.node.add_child(buttons_container)
	var index = 0
	for order in order_types.lumberjack:
		var button = button_template.instantiate()
		buttons_container.add_child(button)
		button.tooltip_text = hint_tooltips_lumberjack[order]
		button.orders = {
			"order": orders,
			"type": "lumberjack",
			"lumberjack": order,
			"hint": hint_keys_up[index]
		}
		index += 1
		setup_order_button(button)
	orders.node.add_child(HSeparator.new())


# CAMPS

func build_camps():
	for building in camp:
		var orders = {
			"node": VBoxContainer.new(),
			"camp": building
		}
		container.add_child(orders.node)
		var side = building.get_parent().name
		camp_orders[building.name+side] = orders
		setup_camp_buttons(orders)


func setup_camp_buttons(orders):
	var label = Utils.label("hire")
	orders.node.add_child(label)
	setup_hire(orders)
	var label2 = Utils.label("taxes")
	orders.node.add_child(label2)
	setup_taxes(orders)


func setup_hire(orders):
	var buttons_container = HBoxContainer.new()
	orders.node.add_child(buttons_container)
	var index = 0
	for hire in order_types.camp_hire:
		var button = button_template.instantiate()
		buttons_container.add_child(button)
		button.tooltip_text = hint_tooltips_hire[hire]
		button.orders = {
			"order": orders,
			"type": "camp_hire",
			"camp_hire": hire,
			"hint": hint_keys_up[index]
		}
		index += 1
		setup_order_button(button)
		if hire == "melee":
			button.button_pressed = true
			button.disabled = true
	orders.node.add_child(HSeparator.new())


# OUTPOSTS

func build_outposts():
	for building in outpost:
		var orders = {
			"node": VBoxContainer.new(),
			"outpost": building
		}
		container.add_child(orders.node)
		var side = building.get_parent().name
		outpost_orders[building.name+side] = orders
		setup_outpost_buttons(orders)


func setup_outpost_buttons(orders):
	var label = Utils.label("tower upgrades")
	orders.node.add_child(label)
	setup_tower_upgrades(orders)
	var label2 = Utils.label("taxes")
	orders.node.add_child(label2)
	setup_taxes(orders)


func setup_tower_upgrades(orders):
	var buttons_container = HBoxContainer.new()
	orders.node.add_child(buttons_container)
	var index = 0
	for upgrade in order_types.tower_upgrades:
		var button = button_template.instantiate()
		buttons_container.add_child(button)
		button.tooltip_text = hint_tooltips_tower_upgrades[upgrade]
		button.orders = {
			"order": orders,
			"type": "tower_upgrades",
			"tower_upgrades": upgrade,
			"hint": hint_keys_up[index]
		}
		index += 1
		setup_order_button(button)
	orders.node.add_child(HSeparator.new())


# TAXES

func setup_taxes(orders):
	var buttons_container = HBoxContainer.new()
	orders.node.add_child(buttons_container)
	var index = 0
	for tax in order_types.taxes:
		var button = button_template.instantiate()
		buttons_container.add_child(button)
		tax_buttons.append(button)
		button.tooltip_text = hint_tooltips_tax[tax]
		button.orders = {
			"order": orders,
			"type": "taxes",
			"taxes": tax,
			"hint": hint_keys_down[index]
		}
		index += 1
		setup_order_button(button)
		if tax == "low":
			button.button_pressed = true
			button.disabled = true
	orders.node.add_child(HSeparator.new())


# TACTICS

func setup_tactics(orders_container, tactics):
	var buttons_container = HBoxContainer.new()
	orders_container.node.add_child(buttons_container)
	var index = 0
	for tactic in tactics:
		var button = button_template.instantiate()
		button.tooltip_text = hint_tooltips_tactics[tactic]
		button.orders = {
			"order": orders_container,
			"type": "tactic",
			"tactic": tactic,
			"hint": hint_keys_up[index]
		}
		index += 1
		if tactic == "default":
			button.button_pressed = true
			button.disabled = true
		buttons_container.add_child(button)
		setup_order_button(button)
	
	orders_container.node.add_child(HSeparator.new())


# PRIORITY

func setup_priority(orders_container):
	var buttons_container = HBoxContainer.new()
	orders_container.node.add_child(buttons_container)
	var index = 0
	for priority in order_types.priority:
		var button = button_template.instantiate()
		button.orders =  {
			"order": orders_container,
			"type": "priority",
			"priority": priority,
			"hint": hint_keys_down[index]
		}
		index += 1
		button.set_toggle_mode(false)
		button.set_action_mode(true)
		buttons_container.add_child(button)
		setup_order_button(button)
	var first = buttons_container.get_child(0)
	first.set_pressed(true)
	first.set_disabled(true)



func setup_order_button(button):
	#await get_tree().idle_frame
	button.setup_order_button()


func update():
	hide_all()
	var unit = WorldState.get_state("selected_unit")
	if game.can_control(unit):
		if not unit.subtype == "backwood":
			show_orders()
			match unit.type:
				"pawn", "building": 
					var lane_order = unit.agent.get_state("lane")+unit.team
					lane_orders[lane_order].node.show()
				"leader": 
					var leader_order = unit.name+unit.team
					if leader_order in leader_orders:
						leader_orders[leader_order].node.show()
		
		else:
			show_orders()
			var neutral_order = unit.name+unit.get_parent().name
			match unit.display_name:
				"camp":
					camp_orders[neutral_order].node.show()
				"mine":
					mine_orders[neutral_order].node.show()
				"blacksmith":
					blacksmith_orders[neutral_order].node.show()
				"lumbermill":
					lumbermill_orders[neutral_order].node.show()
				"outpost":
					outpost_orders[neutral_order].node.show()
			

	else:
		game.ui.orders_button.disabled = true


func show_orders():
	game.ui.orders_button.disabled = false


func hide_all():
	for child in container.get_children():
		child.hide()
	for leader in leader_orders:
		leader_orders[leader].node.hide()
	for lane in lane_orders:
		lane_orders[lane].node.hide()
