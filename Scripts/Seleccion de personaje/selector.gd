extends Control

var selected_character: String = ""

@onready var selected_label = $SelectedLabel
@onready var listo_button = $Panel/GridContainer/ListoButton
@onready var alan_button = $Panel/GridContainer/Alan
@onready var jesus_button = $Panel/GridContainer/Jesus


func _ready():
	listo_button.disabled = true
	
	# Bloquear Jesus
	jesus_button.disabled = true
	jesus_button.modulate = Color(0.3, 0.3, 0.3)


func _on_alan_pressed():
	select_character("Alan")


func select_character(character_name: String):

	selected_character = character_name
	selected_label.text = "Seleccionado: " + character_name
	
	listo_button.disabled = false
	
	highlight_selected()


func highlight_selected():

	alan_button.modulate = Color.WHITE
	
	if selected_character == "Alan":
		alan_button.modulate = Color(1, 1, 0)


func _on_listo_button_pressed():

	if selected_character == "":
		return

	GameData.reset()
	get_tree().change_scene_to_file("res://Escenas/battle.tscn")


func _on_jesus_pressed() -> void:
	pass # Replace with function body.
