extends GameScene

signal start_game

@onready var cursor = $Control/Cursor
@onready var sub_menu = $Control/Control/SubMenu

var selected_element: RichTextLabel = null
var cursor_offset = Vector2(-10, 4)



func _ready() -> void:
	select(0)


func _input(event: InputEvent) -> void:
	if scene_disabled:
		return
	if event.is_action_pressed("down"):
		alter_select(1)
	if event.is_action_pressed("up"):
		alter_select(-1)
	
	if event.is_action_pressed("progress"):
		if !selected_element: # I don't know if this is possible, like, input before a call to ready, but just in case lol just in case... it's not possible!
			return
		match selected_element.get_parsed_text():
			"Settings":
				pass
			"Start Game!":
				game.change_scene_to_file(load("res://name_please/name_please.tscn").instantiate())
			"Credits":
				pass
			"Exit":
				get_tree().quit()


func alter_select(dir: int) -> void:
	$Bloop.play()
	var inx = sub_menu.get_children().find(selected_element) + dir
	select(posmod(inx, len(sub_menu.get_children())))


func select(inx: int) -> void:
	# exit selected state for last selected element
	if selected_element:
		var regex = RegEx.new()
		regex.compile("\\[.*?\\]")
		selected_element.text = regex.sub(selected_element.text, "", true)
	
	selected_element = sub_menu.get_children()[inx]
	
	# move the cursor to be to the right of the selected element
	cursor.position = selected_element.get_global_position() + cursor_offset
	
	# make selected element's text jiggle
	var new_text = "[hwave freq=1 amp=1.0]%s[/hwave]" % [selected_element.text]
	selected_element.text = new_text


