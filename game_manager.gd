extends Node

var card_prefab = preload("res://Assets/Prefabs/card_prefab.tscn")
var card_held: bool
var mousepos: Vector2
var players = []
var games = []


var scene

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
	scene = get_tree().get_current_scene()
	if scene.name == "Menu":
		scene.get_node("Control/Buttons/Host").connect("button_down", select_game)
		scene.get_node("Control/Buttons/Join").connect("button_down", join_game)
		for i in range(games.size()):
			var button = Button.new()
			button.icon = games[i].icon
			button.tooltip_text = games[i].game_name
			button.connect("button_down", select_game)
			button.add_theme_constant_override("icon_max_width", 16)
			scene.get_node("Control/Games_Container").call_deferred("add_child", button)
	pass # Replace with function body.

func add_card(pos: Vector2, value: int, suit: int, scale: float):
	var instance = card_prefab.instantiate()
	instance.set_rank(value)
	instance.set_suit(suit)
	instance.default_pos = pos
	instance.position = pos
	instance.target_scale = scale
	instance.scale.x = scale
	instance.scale.y = scale
	call_deferred("add_child", instance)
	return instance

func select_game():
	scene.get_node("Control/Buttons").visible = false
	scene.get_node("Control/Games_Container").visible = true
	for i in range(games.size()):
		if scene.get_node("Control/Games_Container").get_child(i).has_focus():
			print("game selected is " + games[i].game_name)
			get_tree().change_scene_to_packed(games[i].scene)
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
	pass


func _process(delta: float) -> void:
	if get_tree().get_current_scene() != null:
		scene = get_tree().get_current_scene()
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if scene != null:
			var camera = scene.get_node("Camera")
			mousepos = event.position + camera.position - get_viewport().size * 0.5
