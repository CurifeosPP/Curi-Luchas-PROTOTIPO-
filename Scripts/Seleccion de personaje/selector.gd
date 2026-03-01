extends Control

var selected_character: String = ""

@onready var selected_label = $SelectedLabel
@onready var listo_button = $Panel/GridContainer/ListoButton


func _ready():
	listo_button.disabled = true


func _on_ryu_pressed():
	select_character("Alan")


func _on_scorpion_pressed():
	select_character("Jesus")


func select_character(character_name: String):

	selected_character = character_name

	selected_label.text = "Seleccionado: " + character_name

	listo_button.disabled = false

	highlight_selected_button(character_name)


func highlight_selected_button(character_name: String):

	$Panel/GridContainer/Ryu.modulate = Color.WHITE
	$Panel/GridContainer/Scorpion.modulate = Color.WHITE

	if character_name == "Ryu":
		$Panel/GridContainer/Ryu.modulate = Color(1, 1, 0)
	else:
		$Panel/GridContainer/Scorpion.modulate = Color(1, 1, 0)

func _on_listo_button_pressed() -> void:

	print("[SELECTOR] Botón Listo presionado")

	if selected_character == "":
		print("[SELECTOR] No hay personaje seleccionado")
		return

	GameData.p1_character = selected_character
	print("[SELECTOR] Personaje guardado:", selected_character)

	await get_tree().create_timer(0.15).timeout

	var used_fade: bool = false

	# ---- USAR FADE SI EXISTE ----
	if typeof(Fade) != TYPE_NIL:
		if Fade.has_method("change_scene"):
			print("[SELECTOR] Usando Fade.change_scene")
			await Fade.change_scene("res://Escenas/Menu.tscn")
			used_fade = true
		else:
			print("[SELECTOR] Fade existe pero no tiene change_scene")
	else:
		print("[SELECTOR] Fade no existe como singleton")

	# ---- FALLBACK ----
	if not used_fade:
		print("[SELECTOR] Cambio directo de escena")
		get_tree().change_scene_to_file("res://Escenas/Menu.tscn")
