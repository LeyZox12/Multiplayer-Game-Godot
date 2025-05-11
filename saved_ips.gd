extends Label

var loaded = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	load_saved()
	pass # Replace with function body.

func xor_decrypt(text: PackedByteArray, key: String) -> String:
	var bytes = PackedByteArray()
	for i in text.size():
		bytes.append(text[i] ^ key.unicode_at(i%key.length()))
	return bytes.get_string_from_utf8()

func load_saved():
	for b in $Container.get_children():
		b.queue_free()
	loaded.clear()
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	for i in xor_decrypt(file.get_buffer(file.get_length()), "gamble").split(","):
		loaded.push_back(i.split("/"))
	for ip in loaded:
		print(ip)
		if(ip.size() > 1):
			var button = Button.new()
			button.connect("button_down", $"../../../Server"._on_join_pressed_loaded.bind(ip[0]))
			button.connect("button_down", $"../../../GameManager".join_game)
			button.text = ip[1]
			$"Container".call_deferred("add_child", button)
	file.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
