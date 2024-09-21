extends Node

# WorldState global class
@onready var game = get_tree().get_current_scene()
# This class is an Autoload accessible globaly
# Access the autoload list in godot settings

#runs logic that is only run once per second
var one_sec_timer:Timer
#controls creep spawn rate
var spawn_timer:Timer

enum teams { red, blue }

enum pawns_list { infantry, archer, mounted }

enum neutrals_list { mailboy, lumberjack }

enum leaders_list {
	arthur, 
	bokuden, 
	hongi, 
	joan, 
	lorne, 
	nagato, 
	osman, 
	raja, 
	robin, 
	rollo, 
	sida, 
	takoda, 
	tomyris 
}


var _state = {}

func get_state(state_name, default = null):
	return _state.get(state_name, default)


func set_state(state_name, value):
	_state[state_name] = value


func clear_state():
	_state = {}


func quick_start():
	game.map_manager.current_map = "my_01_map"
	WorldState.set_state("player_team", "blue")
	WorldState.set_state("enemy_team", "red")
	WorldState.set_state("player_leaders_names", ["arthur", "bokuden", "nagato"])
	WorldState.set_state("enemy_leaders_names", ["lorne", "robin", "rollo"])
	WorldState.set_state("game_mode", "match")
	game.start()