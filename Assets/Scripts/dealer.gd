class_name Dealer

extends Node2D

@onready var game_manager = $"../../GameManager"
@onready var table: Table = game_manager.get_node("Table")
@onready var camera = game_manager.camera

@export var player_turn_index = 0
@export var dealer_hand = []

const CARD_SEPARATION = 0.0
var bets = []
var game_state = ""
var card_spacing = 0.3
var table_built = false
var default_card_pos
var anim_done = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.build_table(Vector2(game_manager.players.size() * 2.0, 5), 128, Vector2(100, 100))
	reset()
	default_card_pos = Vector2(table.get_center().x,
							   table.get_center().y - table.get_pixel_size().y * 0.25)

func reset():
	bets.clear()
	if multiplayer.is_server():
		for suit in range(4):
			for rank in range(13):
				var index = rank + suit * 13
				game_manager.add_card(Vector2(0, 0), rank+1, suit, 0.2, true)
			
		game_manager.cards.shuffle()
		for i in range(game_manager.players.size()):
			bets.push_back(0)
			game_manager.players[i].is_ready = false
		game_state = "init_bets"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if game_state == "init_bets":
		game_state = "waiting_for_ready"
		game_manager.camera_pos = default_card_pos
		update_dealer_pos(Vector2(default_card_pos.x, table.pos.y))
		var separation_mult = 0.0
		for i in game_manager.cards:
			while !i.ready:
				pass
			await get_tree().create_timer(0.02).timeout
			i.set_flipped(true)
			i.default_pos = default_card_pos - Vector2(CARD_SEPARATION * separation_mult, CARD_SEPARATION * separation_mult)
			separation_mult += 1
		anim_done = true
	elif game_state == "waiting_for_ready" and anim_done:
		var start = true
		for p in game_manager.players:
			if not p.is_ready:
				start = false
		if multiplayer.is_server() && start:
			game_state = "play"
			give_cards()
	elif game_state == "play" && anim_done:
		game_manager.camera_pos = table.get_tile_center(Vector2(1 + player_turn_index * 2.0, 4))
		if game_manager.players[player_turn_index].is_local_player():
			if game_manager.players[player_turn_index].action == "action1":
				game_manager.players[player_turn_index].action = ""
				hit()
			elif game_manager.players[player_turn_index].action == "action2":
				game_manager.players[player_turn_index].action = ""
				stay()

func update_dealer_pos(pos: Vector2):
	position = pos
	
func take_card():
	game_manager.used_cards += 1
	var index = 52 - game_manager.used_cards
	game_manager.cards[index].z_index = game_manager.used_cards
	return index

func give_cards():
	anim_done = false
	for p in game_manager.players:
		p.money -= p.bet
	
	for i in range(2):
		await get_tree().create_timer(0.5).timeout
		var index = take_card()
		dealer_hand.push_back(index)
		
		game_manager.cards[index].default_pos =default_card_pos +  Vector2(-40 + i * 80, 160)
		print(index)
		await get_tree().create_timer(0.2).timeout
		if i == 0 || get_sum([dealer_hand[0], dealer_hand[1]]) == 21:
			game_manager.cards[dealer_hand[i]].flip()
	for i in range(game_manager.players.size()):
		await get_tree().create_timer(0.5).timeout
		var index = take_card()
		print(index)
		game_manager.players[i].hand.append(index)
		game_manager.cards[index].default_pos = table.get_tile_center(Vector2(1+i*2.0, 4))
		await get_tree().create_timer(0.2).timeout
		game_manager.cards[index].flip()
	anim_done = true


func hit():
	anim_done = false
	await get_tree().create_timer(0.5).timeout
	var index = take_card()
	game_manager.cards[index].default_pos = table.get_tile_center(Vector2(1+player_turn_index*2.0 + 0.3 * game_manager.players[player_turn_index].hand.size(), 4))
	#game_manager.cards[index].default_pos += Vector2(100, 0)
	game_manager.players[player_turn_index].hand.append(index)
	await get_tree().create_timer(0.2).timeout
	game_manager.cards[index].flip()
	anim_done = true
	player_turn_index = (player_turn_index + 1) % game_manager.players.size()

func stay():
	player_turn_index += 1
	game_manager.players[player_turn_index].folded = true
	pass

func get_sum(cards_arr: Array):
	var aces = 0
	var sum = 0
	for c in cards_arr:
		if game_manager.cards[c].rank == 1:
			aces += 1
			sum += 11
		else:
			sum += game_manager.cards[c].rank
	for a in range(aces):
		if sum > 21:
			sum -= 10
	print(sum)
	return sum
