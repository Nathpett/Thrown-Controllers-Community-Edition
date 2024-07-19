class_name Credtis
extends GameScene

@onready var text = $Control/Control2/Text

var scroll_speed: float = 1.0
var scroll: float = 0


func _ready():
	super._ready()
	var credits_json = load("res://main_menu/credits.json")
	
	text.append_text("[center]")
	for key in credits_json.data:
		
		text.push_color(Color.MEDIUM_BLUE)
		text.add_text(key + "\n")
		text.pop()
		
		for item in credits_json.data[key]:
			text.add_text(item + "\n")
		
		text.add_text(" \n \n")
	
	text.size.y = text.get_content_height()


func _input(event):
	if event.is_action_pressed("left"):
		scroll_speed = -1.0
	if event.is_action_pressed("right"):
		scroll_speed = 2.0
	if event.is_action_released("left") or event.is_action_released("right"):
		scroll_speed = 1.0


func _process(delta):
	scroll += delta * 60.0 * scroll_speed
	$Control/Control2.position.y -= floor(scroll)
	scroll = fmod(scroll, 1.0)
	
	if $Control/Control2.get_global_position().y + $Control/Control2/Text.size.y <= 0:
		main.return_to_main_menu()
		set_process(false)
