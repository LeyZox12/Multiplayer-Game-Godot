class_name Dealer

extends Node

@onready var player = get_parent().get_node("Player")
@onready var game_manager = get_tree().root.get_node("GameManager")
@onready var table: Table = get_parent().get_node("Table")

var cards = []
var players = []
var bets = []
var game_state = ""
var card_spacing = 0.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_priority = 2
	reset()

func reset():
	for i in cards:
		i.queue_free()
	cards.clear()
	bets.clear()
	for suit in range(4):
		for rank in range(13):
			var index = rank + suit * 13
			cards.push_back(game_manager.add_card(Vector2(0, 0), rank+1, suit, 0.2))
	cards.shuffle()
	for i in range(players.size()):
		bets.push_back(0)
		players[i].is_ready = false
	game_state = "init_bets"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_state == "init_bets":
		var pos = Vector2(table.get_center().x - card_spacing, 
				  table.get_center().y - table.get_pixel_size().y * 0.25 - card_spacing)
		for i in game_manager.get_children():
			i.set_flipped(true)
			i.default_pos = pos
		#when all player ready
		if cards.size() != 0:
			give_cards()
func give_cards():
	game_state = "play"
	for i in range(2):
		await get_tree().create_timer(0.5).timeout
		cards[i].default_pos += Vector2(-40 + i * 80, 160)
		await get_tree().create_timer(0.2).timeout
		if i == 1 || get_sum([cards[i], cards[i-1]]) == 21:
			cards[i].flip()
	for i in range(3):
		await get_tree().create_timer(0.5).timeout
		cards[2+i].default_pos = table.get_tile_center(Vector2(1+i*2.0, 4))
		await get_tree().create_timer(0.2).timeout
		cards[2+i].flip()
		
func get_sum(cards_arr: Array):
	var aces = 0
	var sum = 0
	for c in cards_arr:
		if c.rank == 1:
			aces += 1
			sum += 10
		else:
			sum += c.rank
	for a in range(aces):
		if sum > 21:
			sum -= 10
	print(sum)
	return sum
