extends NinePatchRect

@export var ini_centerify: bool = false

var centerified: bool = false
var tween: Tween

@onready var label: RichTextLabel = $MarginContainer/Label



func _ready() -> void:
	tween = create_tween()
	tween.pause()
	show_text(label.text) # for when there are instructions in the category
	
	if ini_centerify:
		centerify()


func show_text(_text: String, tween_time: float = 1.0) -> void:
	if !is_printing() and !_text.is_empty():
#		if _text == label.text and label.visible_ratio == 1.0:
#			return
		label.text = _text
		
		if centerified:
			centerify()
		
		tween.kill()
		tween = create_tween()
		label.visible_ratio = 0.0
		tween.tween_property(label, "visible_ratio", 1.0, tween_time)



func is_printing() -> bool:
	return tween.is_running()


func show_all() -> void:
	tween.kill()
	label.visible_ratio = 1.0


func centerify() -> void:
#	label.valign = Label.VALIGN_CENTER
#	label.align = Label.ALIGN_CENTER
	centerified = true
	label.text = "%s%s%s" % ["[center]", label.text, "[/center]"]


func push_hwave() -> void:
	label.text = "[hwave freq=1 amp=4.0]%s[/hwave]" % [label.text]


func push_shake() -> void:
	label.text = "[shake rate=20.0 level=10]%s[/shake]" % [label.text]


func push_wave() -> void:
	label.text = "[wave amp=40.0 freq=8.0]%s[/wave]" % [label.text]


func clear_bbcode() -> void:
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	label.text = regex.sub(label.text, "", true)
	
	if centerified:
		centerify()
