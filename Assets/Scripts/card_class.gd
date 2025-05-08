class_name card 
extends Node
var holding = false
@export var default_pos: Vector2
var smooth_value = 5
var speed = 100
var mousepos
var rank
var suit
@export var flipped = false
var hovering = false
var dragging = false
@export var target_scale: float = $".".scale.x
var dic = {11:"J",12:"Q",13:"K"}
var default_texture = preload("res://Assets/Sprites/card.png")
var flipped_texture = preload("res://Assets/Sprites/card_back.png")
@onready var to_disable = [
	$label,
	$label2,
	$suit
]
var suit_textures = [
	preload("res://Assets/Sprites/club.png"),
	preload("res://Assets/Sprites/diamond.png"),
	preload("res://Assets/Sprites/heart.png"),
	preload("res://Assets/Sprites/spade.png")
]

@onready var game_manager = $"../../"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if holding and hovering:
		dragging = true
	if dragging:
		$".".position += (mousepos - $".".position) / smooth_value
	elif hovering:
		$".".position.x += (default_pos.x - $".".position.x) / smooth_value
		$".".position.y += (default_pos.y-15 - $".".position.y) / (smooth_value) 
	else:
		$".".position += (default_pos - $".".position) / smooth_value
	if target_scale != $".".scale.x:
		$".".scale.x += (target_scale - $".".scale.x) / smooth_value
		if $".".scale.x < 0.0:
			$background.texture = flipped_texture
			for i in to_disable:
				i.visible = false
		else:
			for i in to_disable:
				i.visible = true
			$background.texture = default_texture
			
			
func get_rank() -> int:
	return rank

func get_suit() -> int:
	return suit

func set_rank(rank: int) -> void:
	var txt = ""
	if rank>10:
		txt = dic[rank]
		rank = 10
	else: 
		txt = str(rank)
	self.rank = rank
	$label.text = txt
	$label2.text = txt

func set_suit(suit: int):
	$suit.texture = suit_textures[suit]
	self.suit = suit

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mousepos = game_manager.mousepos
	if event.is_action_pressed("click") && !game_manager.card_held && hovering:
		holding = true
		game_manager.card_held = true
	elif event.is_action_released("click"):
		holding = false
		dragging = false
		game_manager.card_held = false

func _on_mouse_entered() -> void:
	hovering = true
	pass # Replace with function body.

func _on_mouse_exited() -> void:
	hovering = false
	pass # Replace with function body.

func set_flipped(state: bool):
	if flipped == state:
		return
	flip()
	pass

func flip():
	target_scale = -target_scale
	flipped = !flipped
