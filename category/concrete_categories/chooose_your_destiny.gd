extends ComplexQuestion

var pool: Array
var idx_select: int = 0

func initiate_questions() -> void:
	# get 5 random questions given game state
	# questions cannot have NO_DESTINY token set to true
	# if in devil state, questions cannot have NO_DEVIL TOKENS set to true
	pool = Trivia.CATEGORIES.keys()
	
	pool = pool.filter(Callable(Trivia, "is_destiny"))
	
	
	if game.devil_state:
		pool = pool.filter(Callable(Trivia, "is_devil"))
	
	pool.shuffle()
	pool = pool.slice(0, 5)
	

	dialogue.show_text(get_new_text())


func complx_progress() -> void:
	if idx_select == 0:
		return
	
	pass


func up() -> void:
	idx_select -= 1
	idx_select = posmod(idx_select, pool.size())
	question_label.text = get_new_text()


func down() -> void:
	idx_select += 1
	idx_select = posmod(idx_select, pool.size())
	question_label.text = get_new_text()


func get_new_text() -> String:
	var new_text: PackedStringArray = PackedStringArray()
	
	var i = 0
	for cat in pool:
		var arrow = "->" if i == idx_select else "  "
		new_text.append("%s%s (+%s)" % [arrow, cat.capitalize(), Trivia.get_destiny_value(cat)])
		i += 1
	
	return "\n".join(new_text)
