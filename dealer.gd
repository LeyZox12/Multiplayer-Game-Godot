class_name Dealer

extends Node2D
#TODO FIX LOBBY, IP SAVE SYSTEM CRYPTED
@onready var game_manager = $"../../GameManager"
@onready var table: Table = game_manager.get_node("Table")
@onready var camera = game_manager.camera

@export var player_turn_index = 0
var dealer_hand = []
@export var dealer_hand_value = 0

const CARD_SEPARATION = 0.0
const HELD_CARD_SEPARATION = 0.2

@export var game_state = ""
var card_spacing = 0.3
var table_built = false
var default_card_pos
var anim_done = false
var current_player_action = ""
@export var player_turn_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.build_table(Vector2(game_manager.players.size() * 2.0, 5), 128, Vector2(get_viewport().size / 2.0))
	reset()
	default_card_pos = Vector2(table.get_center().x,
							   table.get_center().y - table.get_pixel_size().y * 0.25)

func reset():
	if multiplayer.is_server():
		for suit in range(4):
			for rank in range(13):
				var index = rank + suit * 13
				game_manager.add_card(Vector2(0, 0), rank+1, suit, 0.2, true)
		await get_tree().create_timer(0.5).timeout
		game_manager.shuffle_cards()
		game_state = "init_bets"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not multiplayer.is_server(): return
	if game_state == "init_bets":
		game_state = "waiting_for_ready"
		game_manager.camera_pos = default_card_pos
		update_dealer_pos(Vector2(default_card_pos.x, table.pos.y))
		anim_done = false
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
			for p in game_manager.players:
				game_manager.players_money[p.name] -= p.bet
			give_cards()
	elif game_state == "play" && anim_done:
		game_manager.camera_pos = table.get_tile_center(Vector2(1 + player_turn_index * 2.0, 4))
		if game_manager.players[player_turn_index].name in game_manager.folded_players:
			player_turn_increment()
		elif game_manager.players[player_turn_index].action == "action2" or get_sum(game_manager.players[player_turn_index].hand) >= 21:
			stay()
			print("skipping player " + str(get_sum(game_manager.players[player_turn_index].hand)))
		elif game_manager.players[player_turn_index].action == "action1":
			hit()
		
		if game_manager.folded_players.size() == game_manager.players.size():
			game_state = "dealer_play"
	elif game_state == "dealer_play":
		if anim_done:
			game_manager.cards[dealer_hand[1]].set_flipped(false)
			var hand_value = get_sum(dealer_hand)
			var should_stay = true
			if hand_value < 17:
				for p in game_manager.players:
					if get_sum(p.hand) > hand_value and get_sum(p.hand) < 21:
						should_stay = false
			if !should_stay:
				dealer_hit()
			else:
				game_state = "give_money"
	elif game_state == "give_money":
		game_state = "reset"
		
		var dealer_value = get_sum(dealer_hand)
		print(dealer_value)
		anim_done = false
		var index = 0
		for p in game_manager.players:
			var hand_value = get_sum(p.hand)
			if hand_value <= 21:
				if (hand_value > dealer_value) or (dealer_hand_value > 21):
					show_result("win", index)
					game_manager.players_money[p.name] += p.bet * 1.5 if hand_value < 21 else 2.0
				elif hand_value == dealer_value:
					game_manager.players_money[p.name] += p.bet
					show_result("tie", index)
				else:

					show_result("lose", index)
			else:
				
				show_result("lose", index)
			await get_tree().create_timer(1.0).timeout
			index += 1
		anim_done = true
		
	elif game_state == "reset" and anim_done:
		await get_tree().create_timer(1).timeout
		game_state = "init_bets"
		dealer_hand.clear()
		player_turn_index = 0
		await get_tree().create_timer(3.0).timeout
		game_manager.shuffle_cards()
		

func show_result(result: String, index: int):
	var pos = table.get_tile_center(Vector2(1+index*2.5, 4)) - Vector2(0, 20)
	var element
	if result == "win":
		element = $Won
	elif result == "lose":
		element = $Lost
	elif result == "tie":
		element = $Tie
	game_manager.camera_pos = table.get_tile_center(Vector2(1 + index * 2.0, 4))
	element.global_position = pos - Vector2(0, 150)
	element.should_fall = true
	element.vel = Vector2(0, -50)
	element.rotation = 0
	element.rotation_vel = 10 * -1 if randi()%2 == 0 else 1

func dealer_hit():
	anim_done = false
	await get_tree().create_timer(0.5).timeout
	var index = take_card()

	dealer_hand.push_back(index)
	
	game_manager.cards[index].default_pos += Vector2(-40 + (dealer_hand.size()-1) * 80, 160)
	await get_tree().create_timer(0.2).timeout
	game_manager.cards[index].set_flipped(false)
	anim_done = true

func update_dealer_pos(pos: Vector2):
	$Sprite.global_position = pos

func update_dealer_hand_value(hand: Array):
	dealer_hand_value = get_sum(hand)

func take_card():
	game_manager.used_cards += 1
	var index = 52 - game_manager.used_cards
	game_manager.cards[index].z_index = game_manager.used_cards
	return index

func give_cards():
	await get_tree().create_timer(1).timeout
	anim_done = false
	for i in range(2):
		await get_tree().create_timer(0.5).timeout
		var index = take_card()
		dealer_hand.push_back(index)
		game_manager.cards[index].default_pos =default_card_pos +  Vector2(-40 + i * 80, 160)
		await get_tree().create_timer(0.2).timeout
		if i == 0 || get_sum([dealer_hand[0], dealer_hand[1]]) == 21:
			game_manager.cards[dealer_hand[i]].set_flipped(false)
	for i in range(game_manager.players.size()):
		await get_tree().create_timer(0.5).timeout
		var index = take_card()
		game_manager.players[i].hand.append(index)
		game_manager.cards[index].default_pos = table.get_tile_center(Vector2(1+i*2.0, 4))
		await get_tree().create_timer(0.2).timeout
		game_manager.cards[index].set_flipped(false)
	anim_done = true

func player_turn_increment():
	player_turn_index = (player_turn_index + 1) % game_manager.players.size()

func hit():
	anim_done = false
	var p_index = player_turn_index
	player_turn_increment()
	await get_tree().create_timer(0.5).timeout
	var index = take_card()
	game_manager.cards[index].default_pos = table.get_tile_center(Vector2(1+p_index* 2.0 + HELD_CARD_SEPARATION * game_manager.players[p_index].hand.size(), 4))
	game_manager.players[p_index].hand.append(index)
	await get_tree().create_timer(0.2).timeout
	game_manager.cards[index].flip()
	anim_done = true
	

	game_manager.get_local_player().reset_action()

func stay():
	game_manager.folded_players.push_back(game_manager.players[player_turn_index].name)
	player_turn_increment()
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
	return sum
