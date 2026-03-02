extends Node2D

@export var dialogue_path: String = "res://Dialogo/untitled.dialogue"
@export var start_node: String = ""
@export var next_scene_path: String = "res://Escenas/Selector.tscn"
@export var gameplay_groups: Array = ["gameplay"]
@export var debug: bool = true

@onready var skip_label: Label = $SkipLabel

var transition_started: bool = false
var can_skip: bool = false

func _ready() -> void:
	await get_tree().process_frame
	
	if debug:
		print("[CINEMATICA] inicio")
	
	_set_gameplay_enabled(false)
	set_process_input(true)

	# Mostrar mensaje inicial
	if skip_label:
		skip_label.text = "Espera..."
	
	var resource = load(dialogue_path)
	if resource == null:
		push_error("[CINEMATICA] No se pudo cargar: " + dialogue_path)
		_set_gameplay_enabled(true)
		return

	if DialogueManager.has_signal("dialogue_ended"):
		if not DialogueManager.is_connected("dialogue_ended", Callable(self, "_on_dialogue_ended")):
			DialogueManager.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))

	if start_node != "":
		DialogueManager.show_dialogue_balloon(resource, start_node)
	else:
		DialogueManager.show_dialogue_balloon(resource)

	# Empezar monitor de escritura
	monitor_typing_state()


# ==================================================
# MONITOREAR ESTADO DE ESCRITURA
# ==================================================

func monitor_typing_state():
	while not transition_started:
		
		var typing := false
		
		# Intentar detectar si el dialogue manager está escribiendo
		if DialogueManager.has_method("is_typing"):
			typing = DialogueManager.is_typing()
		elif "typing" in DialogueManager:
			typing = DialogueManager.typing
		elif "is_writing" in DialogueManager:
			typing = DialogueManager.is_writing
		
		if typing:
			can_skip = false
			if skip_label:
				skip_label.text = "Espera..."
		else:
			can_skip = true
			if skip_label:
				skip_label.text = "Presiona E para saltar"
		
		await get_tree().process_frame


# ==================================================
# DETECTAR TECLA E
# ==================================================

func _input(event):
	if transition_started:
		return
	
	if event.is_action_pressed("skip_cinematic"):
		if not can_skip:
			if debug:
				print("[CINEMATICA] Intento de salto bloqueado (escribiendo)")
			return
		
		if debug:
			print("[CINEMATICA] Saltando cinemática")
		
		_skip_cinematic()


# ==================================================
# TERMINA NORMALMENTE
# ==================================================

func _on_dialogue_ended(_resource = null) -> void:
	if transition_started:
		return
	
	transition_started = true
	can_skip = false
	
	_cleanup_dialogue_signal()
	await get_tree().create_timer(0.15).timeout
	await _go_to_next_scene()


# ==================================================
# SALTAR
# ==================================================

func _skip_cinematic():
	if transition_started:
		return
	
	transition_started = true
	can_skip = false

	if DialogueManager.has_method("hide_dialogue_balloon"):
		DialogueManager.hide_dialogue_balloon()

	_cleanup_dialogue_signal()
	await _go_to_next_scene()


# ==================================================
# TRANSICIÓN
# ==================================================

func _go_to_next_scene() -> void:
	_set_gameplay_enabled(true)

	if typeof(Fade) != TYPE_NIL and Fade.has_method("change_scene"):
		await Fade.change_scene(next_scene_path)
	else:
		get_tree().change_scene_to_file(next_scene_path)


# ==================================================
# LIMPIEZA
# ==================================================

func _cleanup_dialogue_signal():
	if DialogueManager.has_signal("dialogue_ended") and DialogueManager.is_connected("dialogue_ended", Callable(self, "_on_dialogue_ended")):
		DialogueManager.disconnect("dialogue_ended", Callable(self, "_on_dialogue_ended"))


# ==================================================
# GAMEPLAY CONTROL
# ==================================================

func _set_gameplay_enabled(enabled: bool) -> void:
	for group_name in gameplay_groups:
		for node in get_tree().get_nodes_in_group(group_name):
			if node == null:
				continue
			if node.has_method("set_process"):
				node.set_process(enabled)
			if node.has_method("set_physics_process"):
				node.set_physics_process(enabled)
			if node.has_method("set_process_input"):
				node.set_process_input(enabled)
