class_name Player
extends Node

@export var money: int = 1000
@export var id: int
@export var action: String = "None"
@export var user_name: String = "Guest"
@export var is_ready = false
@export var bet = 0
@export var folder = false

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
	game_manager.camera = camera
	camera.move_to(game_manager.camera_pos, 50.0)
	if game_manager.current_game == "BlackJack" && is_local_player():
		if game_manager.current_game == "Menu":
			$"Camera/UI/Menu/Lobby_text".text = "lobby:\n"
			for i in $"../".get_children():
				if i.get_class() == "Node2D":
					$"Camera/UI/Menu/Lobby_text".text += i.user_name + "\n"
			if is_multiplayer_authority() && $"Camera/UI/Menu/Lobby_text/Name".text != "":
				user_name = $"Camera/UI/Menu/Lobby_text/Name".text
	pass

func _on_scene_change(scene_name: String):
	for e in ui.get_children():
		e.visible = false
	if scene_name == "BlackJack":
		ui.get_node("Blackjack").visible = true
		camera.move_to($"../../BlackJack/Table".get_center(), 50.0)
func toggle_ready():
	if is_local_player():
		is_ready = !is_ready
	
func action1():
	action = "action1"

func action2():
	action = "action2"

func action3():
	action = "action3"

func is_local_player() -> bool:
	return multiplayer.get_unique_id() == get_multiplayer_authority()
