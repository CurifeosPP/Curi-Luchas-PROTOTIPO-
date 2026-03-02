extends Control  

var selected_character: String = ""

@onready var selected_label = $SelectedLabel
@onready var listo_button = $Panel/GridContainer/ListoButton
@onready var alan_button = $Panel/GridContainer/Alan
@onready var jesus_button = $Panel/GridContainer/Jesus
@onready var difficulty_option = $Panel/GridContainer/OptionButton


func _ready():
	listo_button.disabled = true
	
	# Bloquear Jesus (como lo tenías)
	jesus_button.disabled = true
	jesus_button.modulate = Color(0.3, 0.3, 0.3)

	_setup_difficulty_option()


# =========================
# CONFIGURAR OPTION BUTTON
# =========================
func _setup_difficulty_option():

	difficulty_option.clear()

	difficulty_option.add_item("Fácil", 0)
	difficulty_option.add_item("Normal", 1)
	difficulty_option.add_item("Difícil", 2)

	# Selecciona la dificultad actual guardada
	difficulty_option.select(int(GameData.jesus_difficulty))

	difficulty_option.item_selected.connect(_on_difficulty_selected)


func _on_difficulty_selected(index: int):

	match index:
		0:
			GameData.set_difficulty(GameData.Difficulty.EASY)
		1:
			GameData.set_difficulty(GameData.Difficulty.NORMAL)
		2:
			GameData.set_difficulty(GameData.Difficulty.HARD)

	print("Dificultad actual:", GameData.get_difficulty_name())


# =========================
# SELECCIÓN PERSONAJE
# =========================
func _on_alan_pressed():
	select_character("Alan")


func _on_jesus_pressed():
	select_character("Jesus")


func select_character(character_name: String):

	selected_character = character_name
	selected_label.text = "Seleccionado: " + character_name
	listo_button.disabled = false
	
	highlight_selected()


func highlight_selected():

	alan_button.modulate = Color.WHITE
	
	if selected_character == "Alan":
		alan_button.modulate = Color(1, 1, 0)


# =========================
# LISTO
# =========================
func _on_listo_button_pressed():

	if selected_character == "":
		return

	# ❌ YA NO HACEMOS RESET AQUÍ
	get_tree().change_scene_to_file("res://Escenas/battle.tscn")
