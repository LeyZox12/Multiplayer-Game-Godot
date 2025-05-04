extends Node2D

@onready var game_manager = get_tree().root.get_node("GameManager")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	game_manager.build_table(Vector2(3, 3), 128, Vector2(100, 100))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
