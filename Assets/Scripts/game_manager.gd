extends Node

var card_prefab = preload("res://Assets/Prefabs/card_prefab.tscn")
var card_held: bool
var mousepos: Vector2
var players = []
var games = []
var cards:Array = []
signal _on_scene_change(scene_name: String)
@export var current_game = "Menu"
@export var used_cards: int
@onready var server = $"../Server"
var scene
@export var should_reset_action = false
@export var scene_to_go_to = "None"
@export var camera_pos: Vector2
@export var folded_players:Array
@export var players_money:Dictionary

var camera
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_priority = 0
	add_game(
		"BlackJack", 
		preload("res://Scenes/black_jack.tscn"),
		1,
		4,
		preload("res://Assets/Sprites/games/blackjack_icon.png")
	)
	scene = $"../"
	camera_pos = Vector2(get_viewport().size / 2.0)
	if server == null:
		server = $"../Server"
	
	if scene.name == "Menu":
		scene.get_node("Control/Buttons/Host").connect("button_down", select_game)
		scene.get_node("Control/Buttons/Join").connect("button_down", join_game)
		scene.get_node("Control/Buttons/Host").connect("button_down", server._on_host_pressed)
		scene.get_node("Control/Buttons/Join").connect("button_down", server._on_join_pressed)
		for i in range(games.size()):
			var button = Button.new()
			button.icon = games[i].icon
			button.tooltip_text = games[i].game_name
			button.connect("button_down", select_game)
			button.add_theme_constant_override("icon_max_width", 16)
			scene.get_node("Control/Games_Container").call_deferred("add_child", button)
	pass # Replace with function body.

@rpc("reliable")
func add_card(pos: Vector2, value: int, suit: int, scale: float, flipped: bool = false):
	var instance = card_prefab.instantiate()
	instance.set_rank(value)
	instance.set_suit(suit)
	instance.default_pos = pos
	instance.position = pos
	instance.target_scale = scale
	instance.scale.x = scale
	instance.scale.y = scale
	instance.set_flipped(flipped)
	instance.name = "card" + str(value + suit * 13)
	$Cards.call_deferred("add_child", instance)
	if multiplayer.is_server():
		rpc("add_card", pos, value, suit, scale)
	cards.push_back(instance)
	return instance

func get_local_player():
	for p in players:
		if p.is_local_player():
			return p

func build_table(size: Vector2, tile_size: int, offset: Vector2):
	$Table.build(size, tile_size, offset)

func select_game():
	scene.get_node("Control/Buttons").visible = false
	scene.get_node("Control/Games_Container").visible = true
	for i in range(games.size()):
		if scene.get_node("Control/Games_Container").get_child(i).has_focus():
			print("game selected is " + games[i].game_name)
			scene_to_go_to = "BlackJack"
	pass

func add_game(game_name: String, scene: PackedScene, min_players: int, max_players: int, icon: Texture):
	var game = Game.new()
	game.game_name = game_name
	game.scene = scene
	game.min_players = min_players
	game.max_players = max_players
	game.icon = icon
	games.push_back(game)

func join_game():
	scene.get_node("Control/Buttons/Host").visible = false
	scene.get_node("Control/Buttons/Join").visible = false
	pass


func _process(delta: float) -> void:
	if get_tree().get_current_scene() != null:
		scene = get_tree().get_current_scene()
	if scene_to_go_to == "BlackJack":
		change_scene(games[0].scene)
		current_game = "BlackJack"
		scene_to_go_to = "None"
	pass


func shuffle_cards():
	used_cards = 0
	cards.shuffle()
	var index = 2
	for c in cards:
		c.z_index = index
		index += 1

func change_scene(scene: PackedScene):
	for i in $"../".get_children():
		if i.name !="GameManager" && i.name !="Server":
			i.queue_free()
	var instance = scene.instantiate()	
	$"../".add_child(instance)
	_on_scene_change.emit(instance.name)

func set_card_pos(index: int, pos: Vector2):
	$"Cards".get_child(index).default_pos = pos

func move_card(index: int, offset: Vector2):
	$"Cards".get_child(index).default_pos += offset

func update_cards():
	for e in get_children():
		cards.clear()
		if e.get_class() == "Node2D":
			cards.push_back(e)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if scene != null && camera != null:
			mousepos = event.position + camera.position - get_viewport().size * 0.5
