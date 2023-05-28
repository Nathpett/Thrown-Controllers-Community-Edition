class_name GameState
extends Resource

# TODO this won't capture avialable reigon vectors... gotta refactor how that is edited

var panels: Dictionary = {}
var category_queue: Array = []
var current_contestant_name: String = ""
var current_contestant_score: int = 0
var devil_state = false
var point_gain: int = 1
var temp_point_gain: int = 0 # set by choose your destiny
var exhausted_categories: Array = []
var leaderboard: Dictionary = {}
var trivia
var avatar: Avatar


