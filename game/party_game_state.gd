class_name PartyGameState
extends GameState

enum Players{DAD, SAV, SHEN, ALEX, NATE}

@export var players: Dictionary = {
	Players.DAD: "Dad",
	Players.SAV: "Sav",
	Players.SHEN: "Shen",
	Players.ALEX: "Alex",
	Players.NATE: "Nate"
}


func initiate(trivia_path: String, initial_mode: int, _fast_mode: bool = false, shuffle_trivia: bool = false) -> void:
	super.initiate(trivia_path, initial_mode, _fast_mode, shuffle_trivia)


func import_new_questions() -> void: # TODO, check party trivia, import new ones on load?
	pass


# TODO FIX THIS
func add_player(player_enum: int, player_name: String, avatar_coord: Vector2i):
	players[player_enum] = {"name": player_name, "avatar_coord": avatar_coord, "score": 0}
