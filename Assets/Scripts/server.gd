extends Node2D

var peer = ENetMultiplayerPeer.new()
var player_scene = preload("res://Assets/Prefabs/player.tscn")

@onready var game_manager = get_parent().get_node("GameManager")

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_host_pressed():
	peer.create_server(5050)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	
func _add_player(id = 1):
	print("player connected")
	var instance = player_scene.instantiate()
	instance.name = str(id)
	instance.user_name = "guest" + str(id)
	instance.id = id
	if id != multiplayer.get_unique_id():
			instance.visible = false
	call_deferred("add_child", instance)
	
	game_manager.players.push_back(instance)

func _on_join_pressed():
	peer.create_client("localhost", 5050)
	multiplayer.multiplayer_peer = peer
	
