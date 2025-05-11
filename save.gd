extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func xor_decrypt(text: PackedByteArray, key: String) -> String:
	var bytes = PackedByteArray()
	for i in text.size():
		bytes.append(text[i] ^ key.unicode_at(i%key.length()))
	return bytes.get_string_from_utf8()

func save_file():
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	var content = $"../Join/Adress".text + ","
	file.store_buffer(xor_encrypt(content, "gamble"))
	file.close()
	file.store_buffer(xor_encrypt(content, "gamble"))

func xor_encrypt(text: String, key:String):
	var bytes = text.to_utf8_buffer()
	for i in bytes.size():
		bytes[i] ^= key.unicode_at(i%key.length())
	return bytes 
