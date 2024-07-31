class_name CategoryStatics
extends Resource

enum {
	NO_DEVIL,   # Category won't appear in the devil state
	NO_DESTINY, # Category won't appear as option in Chooses Your Destiny
	NO_TRIVIA,  # Category does not need or have any trivia data
	DESTINY_VALUE, # points awarded if chosen and completed in choose your destiny.  Default is 1.
	DEPENDANTS, # category is dependant on another category, and will be removed if that category is exhausted (e.g. devil deal will be removed if no brutal questions)
	VIDEO_GAME_CHALLENGE,
	NOT_SUBSTANTIVE,
	YES_CONTENT, # Trivia requires extra resource -- like an image or audio
	CROWD_ONLY,
	PARTY_VALUE,
	NO_STEAL, # Trvia cannot be stolen in party mode
	} 

const CATEGORIES: Dictionary = {
						"easy_question": {PARTY_VALUE: 10, NO_DEVIL: true}, 
						"solo_video_game_challenge": {PARTY_VALUE: 10, VIDEO_GAME_CHALLENGE: true}, 
						"brutal_question": {PARTY_VALUE: 25, DESTINY_VALUE: 2, DEPENDANTS:["devils_deal"]}, 
						"TheRunawayGuys_video_game_challenge": {PARTY_VALUE: 10, DESTINY_VALUE: 2, VIDEO_GAME_CHALLENGE: true}, 
						"audience_video_game_challenge": {PARTY_VALUE: 10, VIDEO_GAME_CHALLENGE: true},
						"leap_of_faith": {PARTY_VALUE: 10, VIDEO_GAME_CHALLENGE: true},
						"audio": {PARTY_VALUE: 10, YES_CONTENT: true},
						"dialogue": {PARTY_VALUE: 10, YES_CONTENT: true},
						"who_the_heck_is_that": {PARTY_VALUE: 10, YES_CONTENT: true},
						"screenshot": {PARTY_VALUE: 10, YES_CONTENT: true},
						"lightning_round": {NO_STEAL: true, PARTY_VALUE: 10},
						"multiple_choice": {NO_STEAL: true, PARTY_VALUE: 10, NO_DEVIL: true},
						"devils_deal": {PARTY_VALUE: 10, NO_DEVIL: true, NO_DESTINY: true, NO_TRIVIA: true, NOT_SUBSTANTIVE: true},
						"choose_your_destiny": {PARTY_VALUE: 10, NO_DESTINY: true, NO_TRIVIA: true, NOT_SUBSTANTIVE: true, NO_DEVIL: true},
						"pick_your_poison": {PARTY_VALUE: 10, NO_DESTINY: true, VIDEO_GAME_CHALLENGE: true},
						"ericas_game": {NO_STEAL: true, PARTY_VALUE: 20},
						}


static func get_editor_element_path(cat: String):
	if cat == "lightning_round":
		return "res://trivia_editor/editor_elements/lightning_element.tscn"
	if cat == "multiple_choice":
		return "res://trivia_editor/editor_elements/multiple_question_element.tscn"
	
	if cat == "pick_your_poison": 
		return "res://trivia_editor/editor_elements/poison_question_element.tscn"
	
	if cat == "TheRunawayGuys_video_game_challenge":
		return "res://trivia_editor/editor_elements/trg_question_element.tscn"
	
	if cat == "ericas_game":
		return "res://trivia_editor/editor_elements/erica_element.tscn"
	
	if CategoryStatics.has_content(cat): 
		return "res://trivia_editor/editor_elements/content_question_element.tscn"
	
	if CategoryStatics.is_video_game_challenge(cat):
		return "res://trivia_editor/editor_elements/challenge_element.tscn"
	
	return "res://trivia_editor/editor_elements/simple_question_element.tscn"


static func has_content(cat) -> bool:
	return CATEGORIES[cat].get(YES_CONTENT, false)

# will category show up in devil state
static func is_devil(cat) -> bool:
	return !CATEGORIES[cat].get(NO_DEVIL, false)

# will category show up in choose your destiny
static func is_destiny(cat) -> bool:
	return !CATEGORIES[cat].get(NO_DESTINY, false)

static func has_trivia_data(cat) -> bool:
	return !CATEGORIES[cat].get(NO_TRIVIA, false)

static func get_destiny_value(cat) -> int:
	return CATEGORIES[cat].get(DESTINY_VALUE, 1)

static func get_dependants(cat) -> Array:
	return CATEGORIES[cat].get(DEPENDANTS, [])

static func is_video_game_challenge(cat) -> bool:
	return CATEGORIES[cat].get(VIDEO_GAME_CHALLENGE, false)

static func is_not_substantive(cat) -> bool:
	return CATEGORIES[cat].get(NOT_SUBSTANTIVE, false)

static func is_substantive(cat) -> bool:
	return !CATEGORIES[cat].get(NOT_SUBSTANTIVE, false)

static func get_party_value(cat) -> int:
	return CATEGORIES[cat].get(PARTY_VALUE, 10)

static func can_steal(cat) -> bool:
	return !CATEGORIES[cat].get(NO_STEAL, false)
