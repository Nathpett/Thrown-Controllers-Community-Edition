class_name NamePlease
extends GameScene

var swapping:bool = true

@onready var avatar = $Control/Avatar
@onready var on_stage_position = $Control/OnStagePosition
@onready var off_stage_position = $Control/OffStagePosition
@onready var out_stage_position = $Control/OutStagePosition
@onready var keyboard = $Control/Control/Keyboard
@onready var name_this_person = $Control/Control/NameThisPerson/MarginContainer/Label


func _ready() -> void:
	super._ready()
	
	avatar.visible = true
	
	keyboard.connect("ok", Callable(self, "_on_ok"))
	keyboard.connect("swap", Callable(self, "_on_swap"))
	
	call_in_avatar()


func disable() -> void:
	super.disable()
	keyboard.keyboard_disabled = true


func enable() -> void:
	super.enable()
	keyboard.keyboard_disabled = false


func call_in_avatar() -> void:
	avatar.randomize_character()
	avatar.facing = Avatar.Facing.RIGHT
	
	avatar.move_to(on_stage_position.position)
	swapping = false


func swap_avatar() -> void:
	if swapping:
		return
	swapping = true
	
	avatar.facing = Avatar.Facing.LEFT
	
	var tween = create_tween()
	tween.tween_property(avatar, "position", off_stage_position.position, 0.7)
	
	await tween.finished
	
	call_in_avatar()


func call_out_avatar() -> void:
	avatar.move_to(out_stage_position.position)


func _on_ok(contestant_name) -> void:
	# don't progress if name taken
	if !game.game_state.is_contestant_name_available(contestant_name):
		name_this_person.text = "That name is taken"
		return
	
	avatar.confirm_character()
	call_out_avatar()
	
	game.game_state.current_contestant_name = contestant_name
	game.game_state.current_contestant_avatar_reigon = avatar.reigon_vector
	game.avatar.reigon_vector = avatar.reigon_vector
	game.return_to_panel_select()


func _on_swap() -> void:
	swap_avatar()
