class_name Table
extends Node

var size: Vector2
var pos: Vector2
var tile_size: int
var table_sprites = [
	preload("res://Assets/Sprites/table/table_top_left.png"),
	preload("res://Assets/Sprites/table/table_top.png"),
	preload("res://Assets/Sprites/table/table_top_right.png"),
	preload("res://Assets/Sprites/table/table_right.png"),
	preload("res://Assets/Sprites/table/table_bottom_right.png"),
	preload("res://Assets/Sprites/table/table_bottom.png"),
	preload("res://Assets/Sprites/table/table_bottom_left.png"),
	preload("res://Assets/Sprites/table/table_left.png"),
	preload("res://Assets/Sprites/table/table_middle.png")
]

func _init() -> void:
	var instance = Node.new()
	instance.name = "TableContainer"
	add_child(instance)


func build(size: Vector2, tile_size: int, offset: Vector2):
	for i in $TableContainer.get_children():
		if "Sprite2D" in i.name:
			i.queue_free()
	
	self.size = size
	self.pos = offset
	self.tile_size = tile_size
	
	var scale = Vector2(tile_size, tile_size) / table_sprites[0].get_width()
	for y in range(size.y):
		for x in range(size.x):
			var sprite = Sprite2D.new()
			var sprite_index = 0
			sprite.position = Vector2(x * tile_size, y * tile_size) + offset
			if y == 0:
				if x == 0:
					sprite_index = 0
				elif x == size.x - 1:
					sprite_index = 2
				else:
					sprite_index = 1
			elif y == size.y - 1:
				if x == 0:
					sprite_index = 6
				elif x == size.x - 1:
					sprite_index = 4
				else:
					sprite_index = 5
			elif x == 0:
				sprite_index = 7
			elif x == size.x - 1:
				sprite_index = 3
			else:
				sprite_index = 8
			sprite.texture = table_sprites[sprite_index]
			sprite.scale = scale
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			$TableContainer.call_deferred("add_child", sprite)

func get_center():
	return (pos + size * 0.5 * tile_size) - Vector2(tile_size * 0.5, tile_size * 0.5)

func get_tile_center(tile: Vector2):
	return pos + tile * tile_size - Vector2(tile_size * 0.5, tile_size * 0.5)
func get_pixel_size():
	return size * tile_size
