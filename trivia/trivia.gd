class_name Trivia
extends Resource

enum {
	NO_DEVIL,   # Category won't appear in the devil state
	NO_DESTINY, # Category won't appear as option in Chooses Your Destiny
	NO_TRIVIA,  # Category does not need or have any trivia data
	DESTINY_VALUE, # points awarded if chosen and completed in choose your destiny.  Default is 1.
	DEPENDANTS, # category is dependant on another category, and will be removed if that category is exhausted (e.g. devil deal will be removed if no brutal questions)
	VIDEO_GAME_CHALLENGE,
	} 

const CATEGORIES: Dictionary = {
						"easy_question": {NO_DEVIL: true}, 
						"solo_video_game_challenge": {VIDEO_GAME_CHALLENGE: true}, 
						"brutal_question": {DESTINY_VALUE: 2, DEPENDANTS:["devils_deal"]}, 
						"TheRunawayGuys_video_game_challenge": {DESTINY_VALUE: 2, VIDEO_GAME_CHALLENGE: true}, 
						"audience_video_game_challenge": {VIDEO_GAME_CHALLENGE: true},
						"leap_of_faith": {VIDEO_GAME_CHALLENGE: true},
						"audio": {},
						"dialogue": {},
						"who_the_heck_is_that": {},
						"screenshot": {},
						"lightning_round": {},
						"multiple_choice": {NO_DEVIL: true},
						"devils_deal": {NO_DEVIL: true, NO_DESTINY: true, NO_TRIVIA: true},
						"choose_your_destiny": {NO_DESTINY: true, NO_TRIVIA: true},
						"pick_your_poison": {NO_DESTINY: true, VIDEO_GAME_CHALLENGE: true},
						}

# simple questions
@export var easy_question = [{"question": "What year did Zelda: Tears of the Kingdom release", "answer": "2023"}, 
							{"question": "What does the sea saw?", "answer": "I dunno lol"}]
@export var brutal_question = [{"question": "in what year was Nintendo founded?", 
								"answer": "1889"}, 
								#{"question": "WHY?", "answer": "BECAUSE!"},
								]
@export var solo_video_game_challenge = [{"question": "play the game of life"}, {"question": "Katamari"}]
@export var audience_video_game_challenge = [{"question": "play a game"}, {"question": "huhuhuhuhuuu"}]
@export var leap_of_faith = [{"question": "do 10,000 pushups (one handed)"}]

#audio
@export var audio = [{"question": "GBA game is fun to play?", "answer": "Mother 3", "path":"audio/Mother 3 - 129 Even Drier Guys.ogg"}]
@export var dialogue = [{"question": "who's voice is this?", "answer": "Big D. Cat", "path":"dialogue/we better.wav"}]

# visual
@export var who_the_heck_is_that = [{"question":"little boy egg morning?", "answer": "Billy Hatcher", "path":"who_the_heck_is_that/billy.png"}]
@export var screenshot = [{"question":"I hate this boy?", "answer": "John Test", "path":"screenshot/bo.jpg"}]

# true is left, false is right
@export var lightning_round = [
							{"theme": "Is this the name of a mario party minigam or a rhythm heaven rhythm game?",
							"time_limit":30,
							"left":"Mario Party",
							"right":"Rhythm Heaven",
							"questions":[
								["Bombs Away", true],
								["Drummer duel", false],
								["Airboarder", false],
								["Bowl Over", true],
								["Knock Block Tower", true],
#								["Tipsy Tourney", true],
							]},
						]

@export var multiple_choice = [
							{"question": "Mandiblard, Sheargrub, and Crawmads are monsters from which game series?",
							"answers": ["Monster Hunter", "Pokemon", "Pikmin", "Zelda"],
							"answer": 2
							}
]

# a little unique, as it is popped three times instead of once per trivia --- and the two unused challenges are put back in!
@export var pick_your_poison = [
							{"game": "Spelunky 2", "challenge": "1 v 1 Arena"},
							{"game": "Spelunky 3", "challenge": "2 v 2 Arena"},
							{"game": "Spelunky 4", "challenge": "3 v 3 Arena"},
#							{"game": "Spelunky 5", "challenge": "4 v 4 Arena"},
#							{"game": "Spelunky 6", "challenge": "5 v 5 Arena"},
#							{"game": "Spelunky 7", "challenge": "6 v 6 Arena"},
]

@export var TheRunawayGuys_video_game_challenge = {"chuggaaconroy": ["Super Mario Galaxy 2 (Wii) \n Beat the tall Trunk Slide purple coin star, two attempts", 
																	"Do a little dance",
																	],
													"proton_jon": ["make a little love",
																	"get down tonight"
																	],
													"nintendo_capri_sun": ["ha ha ha ha", 
																			"stayin alive"
																	]
}

@export var devils_deal = 0
@export var choose_your_destiny = 0


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
