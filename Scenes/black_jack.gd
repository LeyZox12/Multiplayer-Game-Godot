extends Node2D

@onready var game_manager = get_tree().root.get_node("GameManager")
@onready var CAMERA = $Camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Table.build(Vector2(3, 3), 128, Vector2(100, 100))
	CAMERA.move_to($Table.get_center(), 50.0)
	print($Table.get_center())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
