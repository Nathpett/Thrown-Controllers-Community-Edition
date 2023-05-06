class_name trivia
extends Resource

# simple questions
@export var easy_question = [{"question": "What is 2+2?", "answer": "4"}, 
							{"question": "What does the sea saw?", "answer": "I dunno lol"}]
@export var brutal_question = [{"question": "what is the square root of 48509859038", 
								"answer": "A reasonably large number I'm sure"}, {"question": "WHY?", "answer": "BECAUSE!"}]
@export var solo_video_game_challenge = [{"question": "play the game of life"}, {"question": "Katamari"}]
@export var TheRunawayGuys_video_game_challenge = [{"question": "oh"}, {"question": "TRG 2"}]
@export var audience_video_game_challenge = [{"question": "play a game"}, {"question": "huhuhuhuhuuu"}]
@export var leap_of_faith = [{"question": "do 10,000 pushups (one handed)"}]

#audio
@export var audio = [{"question": "GBA game is fun to play?", "answer": "Mother 3", "path":"audio/Mother 3 - 129 Even Drier Guys.ogg"}]
@export var dialogue = [{"question": "who funny voice man?", "answer": "Big D. Cat", "path":"dialogue/we better.wav"}]

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
							{"question": "what is the correct answer testing how long this can get he he he he heh heh e heh h ehe he he hhe he he he heh heheh hehe he h?",
							"answers": ["this one!!", "wrong answer", "the correct answer", "not this one"],
							"answer": 2
							}
]



@export var devils_deal = 0
