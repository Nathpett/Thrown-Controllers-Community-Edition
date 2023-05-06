class_name Hwave
extends RichTextEffect

# Syntax: [hwave freq=5.0 amp=1.0][/wave]

# Define the tag name.
var bbcode = "hwave"

func _process_custom_fx(char_fx):
	var freq = char_fx.env.get("freq", 5.0)
	var amp = char_fx.env.get("amp", 1.0)
	
	
	char_fx.offset.y = -max(0, amp * -sin(freq * char_fx.elapsed_time - char_fx.glyph_index))
	return true
