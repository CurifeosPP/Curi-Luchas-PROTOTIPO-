extends Node2D

@export var dialogue_path: String = "res://Dialogo/untitled.dialogue"
@export var start_node: String = ""
@export var next_scene_path: String = "res://Escenas/Menu.tscn"
@export var gameplay_groups: Array = ["gameplay"]
@export var debug: bool = true

func _ready() -> void:
	await get_tree().process_frame
	if debug:
		print("[CINEMATICA] inicio")
	_set_gameplay_enabled(false)

	var resource = load(dialogue_path)
	if resource == null:
		push_error("[CINEMATICA] No se pudo cargar: " + dialogue_path)
		_set_gameplay_enabled(true)
		return

	# Conectamos la señal correcta del Dialogue Manager (nombre común: 'dialogue_ended')
	# Evitamos múltiples conexiones
	if DialogueManager.has_signal("dialogue_ended"):
		if not DialogueManager.is_connected("dialogue_ended", Callable(self, "_on_dialogue_ended")):
			DialogueManager.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))
	else:
		# Si no existe la señal, hacemos un intento seguro: mostramos y salimos (no ideal, pero evita romper)
		if debug:
			print("[CINEMATICA] Atención: DialogueManager no tiene la señal 'dialogue_ended' detectada.")

	# Mostrar diálogo (sin await, ya que usamos la señal)
	if start_node != "":
		DialogueManager.show_dialogue_balloon(resource, start_node)
	else:
		DialogueManager.show_dialogue_balloon(resource)


func _on_dialogue_ended(_resource = null) -> void:
	if debug:
		print("[CINEMATICA] señal dialogue_ended recibida")

	# Desconectar para evitar duplicados en futuras escenas
	if DialogueManager.has_signal("dialogue_ended") and DialogueManager.is_connected("dialogue_ended", Callable(self, "_on_dialogue_ended")):
		DialogueManager.disconnect("dialogue_ended", Callable(self, "_on_dialogue_ended"))

	_set_gameplay_enabled(true)

	await get_tree().create_timer(0.15).timeout

	# ----- USAR FADE SI EXISTE -----
	var used_fade: bool = false

	# Comprobación segura del singleton global 'Fade' y su método change_scene (case-sensitive)
	# Nota: el autoload debe llamarse exactamente 'Fade' y su método 'change_scene'
	if typeof(Fade) != TYPE_NIL:
		# Verificamos que tenga el método esperado
		if Fade.has_method("change_scene"):
			if debug:
				print("[CINEMATICA] Usando Fade.change_scene para la transición a:", next_scene_path)
			# Await al cambio de escena para que se ejecute el fade y espere su finalización
			await Fade.change_scene(next_scene_path)
			used_fade = true
		else:
			if debug:
				print("[CINEMATICA] El singleton 'Fade' existe pero no tiene 'change_scene'.")

	# Fallback: si no hay Fade, usamos el cambio directo de escena
	if not used_fade:
		if debug:
			print("[CINEMATICA] Fade no disponible: cambio directo de escena a:", next_scene_path)
		get_tree().change_scene_to_file(next_scene_path)


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
