extends PanelSelect


func _ready():
	super._ready()
	
	await animation_finished
	
	$Control/ScoreBoard.update_scores()
	
	
