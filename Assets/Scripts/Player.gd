class_name Player
extends Node

@export var money: int
@export var id: int
@export var action: String = "None"
@export var user_name: String = "Guest"
@export var is_ready = false
@export var bet = 0
var folded = false

var hand = []

@onready var game_manager = $"../../GameManager"
@onready var camera = $Camera
@onready var ui = $Camera/UI

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	user_name += name

func _ready():

	if name.to_int() != multiplayer.get_unique_id():
		$".".visible = false
	game_manager = $"../../GameManager"
	game_manager.connect("_on_scene_change", _on_scene_change)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#TODO
	
	if is_local_player():
		if name in game_manager.players_money.keys():
			money = game_manager.players_money[name]
		folded = name in game_manager.folded_players
	game_manager.camera = camera
	camera.move_to(game_manager.camera_pos, 50.0)
	if game_manager.should_reset_action == true:
		action = "None"
	if game_manager.current_game == "Menu":
			$"Camera/UI/Menu/Lobby_text".text = "lobby:\n"
			for p in game_manager.players:
				$"Camera/UI/Menu/Lobby_text".text += p.user_name + "\n"
			#if is_multiplayer_authority() && $"Camera/UI/Menu/Lobby_text".text != "":
				#user_name = $"Camera/UI/Menu/Lobby_text".text
	if game_manager.current_game == "BlackJack" && is_local_player():
		if $"../../BlackJack/Dealer".game_state == "reset":
			is_ready = false
			hand.clear()
			game_manager.folded_players.clear()
			$Camera/UI/Ready.visible = true
		bet = ui.get_bet()
		$"Camera/UI/Blackjack/Money".text = "Money:" + str(money)
		game_manager.server.get_node(str(name)).action = action

	pass

func _on_scene_change(scene_name: String):
	for e in ui.get_children():
		e.visible = false
	if scene_name != "Menu":
		ui.get_node("Ready").visible = true
	if scene_name == "BlackJack":
		ui.get_node("Blackjack").visible = true
		
		camera.move_to($"../../BlackJack/Table".get_center(), 50.0)
func toggle_ready():
	if is_local_player() and !is_ready:
		is_ready = !is_ready
		$Camera/UI/Ready.visible = false
	
func action1():
	if is_local_player():
		action = "action1"

func action2():
	if is_local_player():
		action = "action2"

func action3():
	if is_local_player():
		action = "action3"


@rpc("reliable")
func reset_action():
	action = "None"
	if multiplayer.is_server():
		rpc("reset_action")
	

func is_local_player() -> bool:
	return multiplayer.get_unique_id() == get_multiplayer_authority()
