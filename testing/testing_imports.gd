extends Node2D

func _ready():
	# HEY THIS WORKS!!
	var image = Image.new()
	image.load("user://icon.png")
	var t = ImageTexture.new()
	t = t.create_from_image(image)
	$Sprite2D.texture = t

#	load_mp3("user://2-18 Fight Against Kajioh.mp3")
#	load_mp3("res://assets/sound/music/03 Controls.mp3")
#	load_ogg("user://Mother 3 - 129 Even Drier Guys.ogg")
#	load_wav("user://540280__badoink__quantum-ether.wav")
#	load_wav("user://we better.wav")
#	load_mp3("user://we better.wav")


func load_mp3(path:String):
	var file = FileAccess.open(path,FileAccess.READ)
	var bytes: PackedByteArray = file.get_buffer(file.get_length())
	var stream = AudioStreamMP3.new()
	stream.set_data(bytes)
	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.play()


func load_wav(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var bytes = file.get_buffer(file.get_length())
	var stream:AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = AudioServer.get_mix_rate()
	stream.stereo = false
	stream.set_data(bytes)
	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.play()
